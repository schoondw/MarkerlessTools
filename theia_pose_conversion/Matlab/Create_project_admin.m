function status = Create_project_admin(varargin)
% Create_project_admin

% - Detect Theia data folders (.\Data\<subject>\<session>\<TheiaFormatData>\<trial>)
% - Loop through subjects\sessions\data_folders\trials
% - Create trial admin file
% 
% Admin (trials):
% - Columns: subject_folder, session_folder, data_folder, trial, n_skel
% - Save to admin.xlsx, sheet: trials

if ~isfolder('Data')
    error('Current path is not a valid project folder.')
end

%% Parameters
status = false;

% - Admin info
admin_file_default = 'admin.xlsx';
data_folder_default = 'Data';
theia_output_folder_default = 'TheiaFormatData';
theia_pose_base_default = 'pose_filt';
trial_sheet_default = 'trials';
max_rows_default = 1000;
verbose_default = true;

trialVarDef_default = {{... 'subject_folder','string';... 'session_folder','string';...
        'data_folder','string';...
        'trial','string';...
        'n_skel','double';...
        'processing_date','string'}};

%% Parse input arguments
p = inputParser;
p.KeepUnmatched = true;

validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (x > 0) && x==floor(x);
istext = @(x) isstring(x) || ischar(x);

addParameter(p,'admin_file', admin_file_default, istext);
addParameter(p,'data_folder', data_folder_default, istext);
addParameter(p,'theia_output_folder', theia_output_folder_default, istext);
addParameter(p,'theia_pose_base', theia_pose_base_default, istext);
addParameter(p,'trial_sheet', trial_sheet_default, istext);
addParameter(p,'max_rows', max_rows_default, validScalarPosInt);
addParameter(p,'verbose', verbose_default, @islogical);
addParameter(p,'trialVarDef', trialVarDef_default, @iscell);

parse(p,varargin{:});

Opts = p.Results;

%% Identify Theia output folders (subfolders of current dir)
C = textscan(genpath('.'),'%s','Delimiter',';');
idx = endsWith(C{1}, Opts.theia_output_folder);

if sum(idx) == 0
    disp('No Theia output folders found on current path.')
    return
end

datafolder_list = C{1}(idx);
n_datafolders = length(datafolder_list);

%% Initiate trial table

n_vars=size(Opts.trialVarDef,1);

% Initialize table
trial_tab = table('Size',[Opts.max_rows n_vars],...
    'VariableTypes',Opts.trialVarDef(:,2),'VariableNames',Opts.trialVarDef(:,1));

%% Loop through folder structure

row_counter = 0; % Counter for total number of trials

for i_df = 1:n_datafolders
    current_datafolder = datafolder_list{i_df};
    
    % Identify trial folders that may contain data
    D = dir(current_datafolder);
    trial_list = {D([D.isdir]).name};
    trial_list(1:2) = [];
    
    n_trials = length(trial_list);
    
    for i_tr = 1:n_trials
        current_trial = trial_list{i_tr};
        
        % Count number of exported skeletons
        D = dir(fullfile(current_datafolder, current_trial,...
            [Opts.theia_pose_base, '_*.c3d']));
        n_skel = length(D);
        
        if n_skel > 0
            % Write row
            row_counter = row_counter+1;
            
            trial_tab{row_counter,'data_folder'} = string(current_datafolder);
            trial_tab{row_counter,'trial'} = string(current_trial);
            trial_tab{row_counter,'n_skel'} = n_skel;
            
            trial_tab{row_counter,'processing_date'} = string(D(1).date);
        end
    end
end
            
%% Write output to Excel

writetable(trial_tab(1:row_counter,:),Opts.admin_file,...
    'Sheet',Opts.trial_sheet,'WriteMode','overwritesheet');

status = true;

if Opts.verbose
    disp('Project admin ready!')
end