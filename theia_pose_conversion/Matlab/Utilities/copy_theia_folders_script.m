% Copy folders to avoid overwriting data in TheiaFormatData folders
% Run in project root

%% 

admin_file = 'admin_v2.xlsx';
session_sheet = 'sessions_all';

verbose = true;

%% Read admin
session_tab = readtable(admin_file,'Sheet',session_sheet);
n_rows = height(session_tab);

project_path = pwd;

%% 

for i1 = 1:n_rows
    
    % Trial path
    fn = fullfile(project_path,'data',...
        char(session_tab{i1,'subject_folder'}),...
        char(session_tab{i1,'session_folder'}),...
        'TheiaFormatData'...
        );
    
    fnew = fullfile(project_path,'data',...
        char(session_tab{i1,'subject_folder'}),...
        char(session_tab{i1,'session_folder'}),...
        'Theia_processed_v2'...
        );
    
    if isfolder(fn)
        if verbose
            fprintf('- Copying: %s\n', fn)
        end
        
        copyfile(fn,fnew)
    end
    
end

if verbose
    disp('Done!')
end
