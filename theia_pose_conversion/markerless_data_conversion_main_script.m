% Main script for conversion of markerless mocap data to QTM export
% formats.
% 
% Assumes PAF project structure
% 
% Conversion of Theia skeleton data from Theia C3D output to QTM TSV via
% Visual3D MAT export
% 
% Set project root as working directory
% Run script (recommended to run one cell at the time and clear data in between)


%% Create trial admin

Create_project_admin;

% Creates a project admin file in the project root: admin.xlsx
% 
% Review the admin, optionally remove rows to discard further
% processing. The following scripts will process the trials specified in
% the sheet "trials".

%% Extract Theia data and export to Visual3D Matlab files
% This step requires Visual3D to be installed.

% clearvars
Theia_to_V3D_mat;

%% Convert V3D mat files to QTM skeleton representation (QTM .mat export format)

% clearvars
V3D_mat_to_QTM_mat;

%% Convert QTM mat to QTM TSV skeletons (QTM .tsv skeleton format)

% clearvars
QTM_mat_to_tsv;
