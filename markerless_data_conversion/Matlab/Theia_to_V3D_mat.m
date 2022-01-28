% Extract Theia data to Visual3D Matlab export
% 
% Requires Visual3D to be installed on the computer running Matlab
%
% Run in project root
% 
% Loop per trial
% - Specify folder in Visual3D pipeline
% - Open pipeline in Visual3D and run to export to mat files

%% Parameters
v3d_program = 'C:\Program Files\Visual3D x64\Visual3D.exe';
% v3s_template = 'C:\Users\labbuser\Documents\EST\Matlab stuff\EnTimeMent\markerless_data_conversion\Visual3D\theia_pose_filt_x_c3d_to_mat_template.v3s';
v3s_template_path = 'C:\Users\labbuser\Documents\EST\Matlab stuff\EnTimeMent\markerless_data_conversion\Visual3D\';
v3s_template = 'theia_pose_filt_x_c3d_to_mat_template.v3s';
v3s_template_spec = fullfile(v3s_template_path, v3s_template);

v3s_instance_name = 'theia_pose_filt_x_c3d_to_mat.v3s'; % Name of v3s pipeline copied to target folder

admin_file = 'admin.xlsx';
trial_sheet = 'trials';

verbose = true;

%% Read admin
trial_tab = readtable(admin_file,'Sheet',trial_sheet);
n_rows = height(trial_tab);

project_path = pwd;

%% Loop per trial
for i1 = 1:n_rows
    if trial_tab{i1,'n_skel'} < 1
        continue;
    end
    
    % Trial path
    fn = fullfile(project_path,'Data',...
        char(trial_tab{i1,'subject_folder'}),...
        char(trial_tab{i1,'session_folder'}),...
        char(trial_tab{i1,'data_folder'}),...
        char(trial_tab{i1,'trial'})...
        );
    
    if verbose
        fprintf('- Processing trial %d/%d: %s\n', i1, n_rows, fn);
    end
    
    % Open template
    fid_templ = fopen(v3s_template_spec,'r');
    f_templ = fread(fid_templ);
    fclose(fid_templ);
    
    % Replace placeholder '%s' with folder name
    f_pln = strrep(f_templ,'%s',fn);
    
    % Write v3s pipeline to trial folder
    v3s_pipeline = fullfile(fn, v3s_instance_name);
    
    fid_out = fopen(v3s_pipeline,'w');
    fprintf(fid_out,'%s',f_pln);
    fclose(fid_out);
    
    % Open Visual3D and run pipeline
    system_cmd = sprintf('"%s" /s "%s"',v3d_program,v3s_pipeline);
    system(system_cmd);
    
    status = system('tasklist /FI "IMAGENAME eq visual3d.exe" 2>NUL | find /I /N "visual3d.exe">NUL');
    
    while status == 0
        status = system('tasklist /FI "IMAGENAME eq visual3d.exe" 2>NUL | find /I /N "visual3d.exe">NUL');
    end
    
end

if verbose
    disp('Done!')
end
