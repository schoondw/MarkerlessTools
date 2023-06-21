function status = Create_project_admin(varargin)
% Create_project_admin

% - Detect Theia data folders (.\Data\<subject>\<session>\<TheiaFormatData>\<trial>)
% - Loop through subjects\sessions\data_folders\trials
% - Create trial admin file
% 
% Admin (trials):
% - Columns: subject_folder, session_folder, data_folder, trial, n_skel
% - Save to admin.xlsx, sheet: trials

%% Parameters
status = false;

% - Admin info
qtm_project_root_check_default = true;
admin_file_default = 'admin.xlsx';
trial_sheet_default = 'trials';
theia_output_folder_default = 'TheiaFormatData'; % subfolder of qtm trial path
qtm_data_folder_rel_theia_output_folder_default = '..';
qtm_format_output_folder_default = {'theia_data_path','qtm_format'};
theia_pose_base_default = 'pose_filt';
max_trials_default = 1000;
verbose_default = true;

trialVarDef_default = {... 'subject_folder','string';... 'session_folder','string';... 'qtm_project_name','string';... 'qtm_trial_path','string';...
    'theia_data_path','string';...
    'qtm_data_path','string';...
    'qtm_format_output_path','string';...    'qtm_format_output_suffix','string';...
    'trial','string';...
    'n_skel','double';...
    'processing_date','string'};

    
% Fixed parameters
qtm_data_folder = 'Data';

%% Parse input arguments
p = inputParser;
p.KeepUnmatched = true;

validScalarPosInt = @(x) isnumeric(x) && isscalar(x) && (x > 0) && x==floor(x);
istext = @(x) isstring(x) || ischar(x);

addParameter(p,'qtm_project_root_check', qtm_project_root_check_default, @islogical);
addParameter(p,'admin_file', admin_file_default, istext);
addParameter(p,'trial_sheet', trial_sheet_default, istext);
addParameter(p,'theia_output_folder', theia_output_folder_default, istext);
addParameter(p,'qtm_data_folder_rel_theia_output_folder', ...
    qtm_data_folder_rel_theia_output_folder_default, istext);
addParameter(p,'qtm_format_output_folder', qtm_format_output_folder_default, @iscell);
addParameter(p,'theia_pose_base', theia_pose_base_default, istext);
addParameter(p,'max_trials', max_trials_default, validScalarPosInt);
addParameter(p,'verbose', verbose_default, @islogical);
addParameter(p,'trialVarDef', trialVarDef_default, @iscell);

parse(p,varargin{:});

Opts = p.Results;

%% Identify Theia output folders (subfolders of current dir)
if Opts.qtm_project_root_check
    % Require that current folder contains the QTM data folder (weak requirement for a project)
    if ~isfolder(qtm_data_folder)
        disp('Current folder should be QTM project root.')
        return
    end
end

C = textscan(genpath('.'),'%s','Delimiter',';');
idx = endsWith(C{1}, Opts.theia_output_folder);
if sum(idx) == 0
    disp('No Theia output folders found on current path.')
    return
end

theia_datafolder_list = C{1}(idx);
n_datafolders = length(theia_datafolder_list);

%% Initiate trial table

n_vars=size(Opts.trialVarDef,1);

% Initialize table
trial_tab = table('Size',[Opts.max_trials n_vars],...
    'VariableTypes',Opts.trialVarDef(:,2),'VariableNames',Opts.trialVarDef(:,1));

%% Loop through folder structure

row_counter = 0; % Counter for total number of trials

for i_df = 1:n_datafolders
    current_datafolder = theia_datafolder_list{i_df};
    
    qtm_data_path = fullfile(current_datafolder, ...
        Opts.qtm_data_folder_rel_theia_output_folder);
    
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
            
            trial_tab{row_counter,'theia_data_path'} = ...
                string(fullfile(current_datafolder, current_trial));
            trial_tab{row_counter,'qtm_data_path'} = string(qtm_data_path);
            trial_tab{row_counter,'trial'} = string(current_trial);
            trial_tab{row_counter,'n_skel'} = n_skel;
            
            trial_tab{row_counter,'processing_date'} = string(D(1).date);
            
            % Define and add QTM format output dir
            base_folder = trial_tab{row_counter, Opts.qtm_format_output_folder{1}}; % qtm_/theia_data_path
            qtm_format_output_path = fullfile(base_folder, Opts.qtm_format_output_folder{2});
            trial_tab{row_counter,'qtm_format_output_path'} = string(qtm_format_output_path);
            % trial_tab{row_counter,'qtm_format_output_suffix'} = string(Opts.qtm_format_output_suffix);
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