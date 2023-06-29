% Main script for collecting video and Theia processing meta data for
% markerless mocap trials 
%
% Assumes PAF project structure
% 
% Set project root as working directory
% Run script (recommended to run one cell at the time and clear data in between)
% 
% These steps assume that a project admin file (admin.xlsx) is in place,
% for example after running the script
% "markerless_data_conversion_main_script". 
% 
% If there is no admin.xlsx file yet, you will first need to run the
% Create_project_admin function with options from the script
% markerless_data_conversion_main_script.

%% Script options
Opts = struct(...
'admin_file', 'admin.xlsx',...
'trial_sheet', 'trials',...
'meta_sheet', 'trial_metadata',...
'verbose', true,...
'metaVarDef', {{... 
    'n_videocams','doublenan';...
    'n_videoframes','doublenan';...
    'videoframe_rate','doublenan';...
    'video_width','doublenan';...
    'video_height','doublenan';...
    'n_megapix','doublenan';...
    'flag_unequal_no_frames','logical';...
    'flag_unequal_frame_rates','logical';...
    'flag_unequal_video_resolutions','logical';...
    'start_theia_processing','string';...
    'end_theia_processing','string';...
    'theia_processing_time','doublenan';...
    'theia_processing_fps','doublenan'}}...
);    

%% Create new project admin file
% Only perform this step when no project admin has been created yet.
% This step will overwrite the "trials" tab in "admin.xlsx" if it already
% exists.
% 
% For safety reasons this step has been commented out.

% Create_project_admin; 

%% Prepare metadata tab
% Adds tab "trial_metadata" to admin.xlsx

Prepare_metadata(Opts);

%% Video meta data
% Extract video meta data from json file created with help of ffmpeg (see
% info in script)
if ~exist(fullfile(pwd,'extractmiqusvideoinfo_json.bat'),'file')
    fn_bat = which('extractmiqusvideoinfo_json.bat');
    copyfile(fn_bat);
end
system('extractmiqusvideoinfo_json.bat')

Extract_video_info(Opts);

%% Processing stats
% Collect processing time information from time stamps of files
% exported by Theia processing:
% - Time stamp of cal.txt indicates start of Theia processing
% - Time stamps of pose_*.c3d files for respective trials indicate times
%   when trials were finished.

Extract_processing_stats(Opts);
