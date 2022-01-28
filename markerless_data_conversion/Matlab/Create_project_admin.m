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
% - Admin info
admin_file = 'admin.xlsx';
trial_sheet = 'trials';
max_rows = 1000;

verbose = true;

%% Extract subject list
D = dir('./Data');
subject_list = {D([D.isdir]).name};
subject_list(1:2) = [];

n_subjects = length(subject_list);

%% Initiate trial table

% Output variable definitions: name and type
% - Columns: subject_folder, session_folder, data_folder, trial, n_skel
trialVarDef = {... 
    'subject_folder','string';...
    'session_folder','string';...
    'data_folder','string';...
    'trial','string';...
    'n_skel','double';...
    'processing_date','string'...
    };
n_vars=size(trialVarDef,1);

% Initialize table
trial_tab = table('Size',[max_rows n_vars],...
    'VariableTypes',trialVarDef(:,2),'VariableNames',trialVarDef(:,1));

%% Loop through folder structure

row_counter = 0; % Counter for total number of trials

for i_subj = 1:n_subjects
    current_subj = subject_list{i_subj};
    
    % Extract session list
    D = dir(['./Data/', current_subj]);
    session_list = {D([D.isdir]).name};
    session_list(1:2) = [];
    
    n_sessions = length(session_list);
    
    for i_ses = 1:n_sessions
        current_ses = session_list{i_ses};
        
        % Identify subfolders that may contain trial folders
        D = dir(['./Data/', current_subj, '/', current_ses]);
        datafolder_list = {D([D.isdir]).name};
        datafolder_list(1:2) = [];
        
        n_datafolders = length(datafolder_list);
        
        for i_sf = 1:n_datafolders
            current_datafolder = datafolder_list{i_sf};
            
            % Identify trial folders that may contain data
            D = dir(['./Data/', current_subj, '/', current_ses, '/', current_datafolder]);
            trial_list = {D([D.isdir]).name};
            trial_list(1:2) = [];
            
            n_trials = length(trial_list);
            
            for i_tr = 1:n_trials
                current_trial = trial_list{i_tr};
                
                % Count number of exported skeletons
                D = dir(['./Data/', current_subj, '/', current_ses, '/',...
                    current_datafolder, '/', current_trial, '/pose_filt_*.c3d']);
                n_skel = length(D);
                
                % Write row
                row_counter = row_counter+1;
                
                trial_tab{row_counter,'subject_folder'} = string(current_subj);
                trial_tab{row_counter,'session_folder'} = string(current_ses);
                trial_tab{row_counter,'data_folder'} = string(current_datafolder);
                trial_tab{row_counter,'trial'} = string(current_trial);
                trial_tab{row_counter,'n_skel'} = n_skel;
                
                if n_skel > 0
                    trial_tab{row_counter,'processing_date'} = string(D(1).date);
                end
            end
            
        end
        
    end
end

%% Write output to Excel

writetable(trial_tab(1:row_counter,:),admin_file,...
    'Sheet',trial_sheet,'WriteMode','overwritesheet');

if verbose
    disp('Done!')
end