# -*- coding: utf-8 -*-
"""
Created on Thu Jan  6 18:21:16 2022

@author: EST
"""

from pathlib import Path
import pandas as pd

# Parameters
project_root = Path.cwd()
data_folder = Path(project_root, "Data")

session_admin_list = []
col_names = ['subject_folder','session_folder','data_folder','trial','n_skel']

# List of subject folders
subj_list = [x for x in data_folder.iterdir() if x.is_dir()]

# Scan for Theia skeleton output
for subj in subj_list:
    ses_list = [x for x in subj.iterdir() if x.is_dir()]
    for ses in ses_list:
        session_admin_list.append([subj.name, ses.name])

# Convert to data frame and write to Excel
session_admin = pd.DataFrame(session_admin_list, columns=col_names[0:2])

if not Path(project_root,"admin.xlsx").exists():
    session_admin.to_excel(Path(project_root,"admin.xlsx"), sheet_name="sessions", index=False)
else:
    with pd.ExcelWriter(Path(project_root,"admin.xlsx"),
                        mode='a', if_sheet_exists='replace') as writer:
        session_admin.to_excel(writer, sheet_name='sessions', index=False)
