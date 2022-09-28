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
% Alternatively, run the script "Create_project_admin" first.

%% Create new project admin file
% Only perform this step when no project admin has been created yet.
% This step will overwrite the "trials" tab in "admin.xlsx" if it already
% exists.
% 
% For safety reasons this step has been commented out.

% Create_project_admin; 

%% Prepare metadata tab
% Adds tab "trial_metadata" to admin.xlsx

Prepare_metadata;

%% Video meta data
% Extract video meta data from json file created with help of ffmpeg (see
% info in script)

Extract_video_info;

%% Processing stats
% Collect processing time information from time stamps of files
% exported by Theia processing:
% - Time stamp of cal.txt indicates start of Theia processing
% - Time stamps of pose_*.c3d files for respective trials indicate times
%   when trials were finished.

Extract_processing_stats;
