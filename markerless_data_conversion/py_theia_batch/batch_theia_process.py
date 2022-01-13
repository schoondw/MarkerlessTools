from pathlib import Path
import subprocess
from tqdm import tqdm
import pandas as pd

templates_dir = Path("Templates").absolute()
theia_tools_path = templates_dir / "Assets\\Programs\\Theia-Tools\\Theia-Tools.exe"
def run_theia_tools(session_folder: Path):
    theia_format_data_path =  session_folder / "TheiaFormatData"
    theia_batch_commands_dir = templates_dir / "Scripts\\src\\Theia\\theia_batch_commands.txt"
    settings_php_path  =templates_dir / "settings.php"

    command_to_run = f'"{theia_tools_path}" --script process'
    command_to_run += f' --path-to-session-folder "{session_folder}"'
    command_to_run += f' --path-to-batch-commands "{theia_batch_commands_dir}"'
    command_to_run += f' --theia-data-dir "{theia_format_data_path}"'
    command_to_run += f' --settings-php-path "{settings_php_path}"'
    command_to_run += f' --error-log-folder "{session_folder}"'
    print("Running command: ")
    print(command_to_run)
    subprocess.run(command_to_run, shell=True, check=True)
# list out folders to batch process

data_folder = Path("Data").absolute()

# session_folders = [ x for x in (data_folder / "Person 1 and 2_001").glob("*") if x.is_dir()] + [ x for x in (data_folder / "Person 3 and 4_002").glob("*") if x.is_dir()]

# session_folders = (
#     [data_folder / "Group Four_004" / subfolder for subfolder in [f"2021-11-18_Markerless"]]
#     )# f"2021-11-17_Markerless_{num}" for num in [0]

# session_folders = [data_folder / "EST_T1" / "2021-10-13_Markerless"]
# session_folders = [data_folder / "EST_T1" / subfolder for subfolder in [f"2021-10-13_Markerless", f"2021-10-14_Markerless"]]
# session_folders = [ x for x in (data_folder / "EST_T1").glob("*") if x.is_dir()]

# Retrieve trial admin from Excel file
# trial_admin=pd.read_excel("admin.xlsx", sheet_name="trials_all")
session_admin=pd.read_excel("admin.xlsx", sheet_name="sessions")

# process
# for session_folder in tqdm(session_folders):
rows = session_admin.index
for row in tqdm(rows):
    session_folder = Path(data_folder, \
        session_admin.loc[row, 'subject_folder'], \
        session_admin.loc[row, 'session_folder'])
    metadata_file = session_folder / "session.xml"
    if metadata_file.is_file() == False:
        print(f"WARNING! no exports of metadata for {session_folder}")
    else:
        run_theia_tools(session_folder)
# show progress