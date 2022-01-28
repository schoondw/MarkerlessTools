% Convert V3D mat files to QTM skeleton
%
% Steps:
% - Read trial admin
% - Loop through skeletons per trial
% - Add skeleton information to skeleton admin ("skeletons" sheet in admin.xlsx)
% - Save QTM mat containing all skeletons to subfolder QTM_format

%% Parameters
admin_file = 'admin.xlsx';
trial_sheet = 'trials';
skel_sheet = 'skeletons';

theia_version_default = 'Theia3D 2021.2.0.1675'; % Default (used version before meta data was included in the visual3d export)
% theia_version_default = 'Theia3D xxxx.x.x.xxxx';
skel_base = 'pose_filt';

flds_required = {'FRAME_RATE','TIME'};

% Expected Visual3D non-segment data (not critical for correct functioning)
flds_fixed = {'FILE_NAME','FRAME_RATE','ANALOG_VIDEO_FRAME_RATIO','TIME','THEIA3D_VERSION'};

default_model = 'standard';
animation_model = 'animation';
animation_model_segments = {'abdomen','thorax','neck'};

qtm_format_folder = 'qtm_format';

admin_only = false; % Only adds info to admin/skip writing mat file when true
verbose = true;

%% Read admin
trial_tab = readtable(admin_file,'Sheet',trial_sheet);
n_trials = height(trial_tab);

string_vars = {'theia_version'};
if sum(ismember(trial_tab.Properties.VariableNames,string_vars))>0
    trial_tab = convertvars(trial_tab,string_vars,'string');
end

project_path = pwd;

% Project name
i_filesep = strfind(project_path,filesep);
project_name = project_path(i_filesep(end)+1:end);


%% Initiate skeleton table

% Output variable definitions: name and type
% Columns (from admin): subject_folder, session_folder, data_folder, trial
% New columns: n_frames, frame_rate,
%   skel_id, fill_level_av, fill_level_sd, fill_level_min, fill_level_max
skelVarDef = {... 
    'subject_folder','string';...
    'session_folder','string';...
    'data_folder','string';...
    'trial','string';...
    'processing_date','string';...
    'theia_version','string';...
    'model','string';...
    'n_frames','double';...
    'frame_rate','double';...
    'skel_id','string';...
    'n_segments','double';...
    'fill_level_av','double';...
    'fill_level_sd','double';...
    'fill_level_min','double';...
    'fill_level_max','double'...
    };
n_vars=size(skelVarDef,1);

max_rows = n_trials*10;

% Initialize table
skel_tab = table('Size',[max_rows n_vars],...
    'VariableTypes',skelVarDef(:,2),'VariableNames',skelVarDef(:,1));


%% Loop per trial (row in admin)

% Initiate variables
row_counter = 0; % counter for total number of skeletons

for i_trial = 1:n_trials
    
    n_skel = trial_tab{i_trial,'n_skel'};
    if n_skel < 1
        continue;
    end
    
    trial_name = char(trial_tab{i_trial,'trial'});
    
    % Trial path
    fn_partial_qtm = fullfile(project_name,'Data',...
        char(trial_tab{i_trial,'subject_folder'}),...
        char(trial_tab{i_trial,'session_folder'})...
        );
    
    fn = fullfile(project_path,'Data',...
        char(trial_tab{i_trial,'subject_folder'}),...
        char(trial_tab{i_trial,'session_folder'}),...
        char(trial_tab{i_trial,'data_folder'}),...
        char(trial_tab{i_trial,'trial'})...
        );
    
    if verbose
        fprintf('- Processing trial %d/%d: %s\n', i_trial, n_trials, fn);
    end
    
    % Initiate QTM data structure (Matlab export format)
    qtm = struct(...
        'File',fullfile(fn_partial_qtm, [trial_name, '.qtm']),...
        'Timestamp',[],...
        'StartFrame',1,...
        'Frames',[],...
        'FrameRate',[],...
        'Skeletons',struct([]));
    
    for i_skel = 1:n_skel
        skel_name = sprintf('%s_%d', skel_base, i_skel-1);
        
        if verbose
            fprintf('-- Skel: %s (%d/%d)\n', skel_name, i_skel, n_skel);
        end
        
        % Read skeleton file and extract info
        S = load(fullfile(fn, [skel_name, '.mat']));
        flds = fieldnames(S);
        
        % Check requirements
        if prod(isfield(S,{'TIME','FRAME_RATE'}))<1
            if verbose
                fprintf('     TIME or FRAME_RATE info missing in %s.\n',...
                    [skel_name, '.mat']);
            end
            continue;
        end
        
        n_frames = length(S.TIME{1});
        frame_rate = S.FRAME_RATE{1};
        
        theia_version = theia_version_default;
        if isfield(S,'THEIA3D_VERSION')
            theia_version = sprintf('Theia3D %d.%d.%d.%d',S.THEIA3D_VERSION{1});
        end
        
        if i_skel == 1
            qtm.Frames = n_frames;
            qtm.FrameRate = frame_rate;
        end
        
        segment_labels = setdiff(flds, flds_fixed, 'stable')';
        n_segments = length(segment_labels);
        
        % Convert to QTM position and rotation multidim matrix representation (rigid body)
        pos = nan(3,n_segments,n_frames);
        rot = nan(9,n_segments,n_frames);
        
        segm_cnt = 0;
        segm_keep = true(1,n_segments);
        for i_segm=1:n_segments
            lab = segment_labels{i_segm};
            
            % Check validity of segment data
            if prod(size(S.(lab){1})==[n_frames 17])<1
                segm_keep(i_segm) = false;
                continue;
            end
            
            segm_cnt = segm_cnt + 1;
            
            % Positions in mm (c3d export is in m)
            pos(1,segm_cnt,:) = permute(S.(lab){1}(:,4), [3 2 1])*1000;
            pos(2,segm_cnt,:) = permute(S.(lab){1}(:,8), [3 2 1])*1000;
            pos(3,segm_cnt,:) = permute(S.(lab){1}(:,12), [3 2 1])*1000;
            
            % Rotation matrix elements (mapping to QTM 6DOF rotation matrix representation)
            rot(1,segm_cnt,:) = permute(S.(lab){1}(:,1), [3 2 1]);
            rot(2,segm_cnt,:) = permute(S.(lab){1}(:,5), [3 2 1]);
            rot(3,segm_cnt,:) = permute(S.(lab){1}(:,9), [3 2 1]);
            rot(4,segm_cnt,:) = permute(S.(lab){1}(:,2), [3 2 1]);
            rot(5,segm_cnt,:) = permute(S.(lab){1}(:,6), [3 2 1]);
            rot(6,segm_cnt,:) = permute(S.(lab){1}(:,10), [3 2 1]);
            rot(7,segm_cnt,:) = permute(S.(lab){1}(:,3), [3 2 1]);
            rot(8,segm_cnt,:) = permute(S.(lab){1}(:,7), [3 2 1]);
            rot(9,segm_cnt,:) = permute(S.(lab){1}(:,11), [3 2 1]);
        end
        
        % Corrections in case of invalid segment data
        if segm_cnt<n_segments
            n_segments = segm_cnt;
            segment_labels = segment_labels(segm_keep);
            pos = pos(:,1:segm_cnt,:);
            rot = rot(:,1:segm_cnt,:);
            if verbose
                disp('     Invalid segment data ignored.')
            end
        end
        
        model = default_model;
        if prod(ismember(animation_model_segments,segment_labels))==1
            model = animation_model;
        end
        
        % QTM rigid body-like structure
        qtm_skel = struct(...
            'SkeletonName',skel_name,...
            'Solver',sprintf('%s-%s', theia_version, model),...
            'Scale',1,...
            'Reference','Global',...
            'NrOfSegments',n_segments,...
            'SegmentLabels',{segment_labels},...
            'PositionData',pos,...
            'RotationData',rot);
        
        % Parse into QTMTools skeleton class
        mc_skel = skeleton(qtm_skel);
        
        % Substitute rotation data (from rot matrix to quaternions)
        qrot = [mc_skel.Segments.Rotation];
        xyzw = [qrot.vector; shiftdim(qrot.real,-1)];
        qtm_skel.RotationData = permute(xyzw,[1 3 2]);
        
        % Add skeleton structure to qtm structure
        qtm.Skeletons = [qtm.Skeletons qtm_skel];
        
        % Extract fill levels per segment
        segm_fill_perc = sum(~isnan(squeeze(pos(1,:,:))),2)./n_frames*100;
        
        % Add row to skel_tab
        row_counter = row_counter+1;
        
        skel_tab(row_counter,'subject_folder') = trial_tab(i_trial,'subject_folder');
        skel_tab(row_counter,'session_folder') = trial_tab(i_trial,'session_folder');
        skel_tab(row_counter,'data_folder') = trial_tab(i_trial,'data_folder');
        % skel_tab(row_counter,'trial') = trial_tab(i_trial,'trial');
        skel_tab{row_counter,'trial'} = string(trial_name);
        skel_tab(row_counter,'processing_date') = trial_tab(i_trial,'processing_date');
        skel_tab{row_counter,'theia_version'} = string(theia_version);
        skel_tab{row_counter,'model'} = string(model);
        skel_tab{row_counter,'n_frames'} = n_frames;
        skel_tab{row_counter,'frame_rate'} = frame_rate;
        skel_tab{row_counter,'skel_id'} = string(skel_name);
        skel_tab{row_counter,'n_segments'} = n_segments;
        skel_tab{row_counter,'fill_level_av'} = mean(segm_fill_perc);
        skel_tab{row_counter,'fill_level_sd'} = std(segm_fill_perc);
        skel_tab{row_counter,'fill_level_min'} = min(segm_fill_perc);
        skel_tab{row_counter,'fill_level_max'} = max(segm_fill_perc);
        
    end
    
    % Add Theia version info to trial tab
    trial_tab{i_trial,'theia_version'} = string(theia_version);
    
    % Save QTM mat file containing all skeletons
    if ~admin_only
        if ~exist(fullfile(fn,qtm_format_folder),'dir')
            mkdir(fn,qtm_format_folder);
        end
        save(fullfile(fn,qtm_format_folder, [trial_name, '.mat']), 'qtm');
    end
    
end


%% Write skeleton tab to Excel

% Update trial tab (added Theia version info)
writetable(trial_tab,admin_file,...
    'Sheet',trial_sheet,'WriteMode','overwritesheet');

% Add/replace skeleton tab
writetable(skel_tab(1:row_counter,:),admin_file,...
    'Sheet',skel_sheet,'WriteMode','overwritesheet');

if verbose
    disp('Done!')
end

