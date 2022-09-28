# -*- coding: utf-8 -*-
"""
Created on Thu Jan  6 18:21:16 2022

@author: EST
"""

from pathlib import Path
import pandas as pd

# Parameters
# data_folder = Path("Data").absolute()
project_root = Path.cwd()
data_folder = Path(project_root, "Data")
# qtm_proj_folder = project_root.resolve().parent

session_admin_list = []
trial_admin_list = []
col_names = ['subject_folder','session_folder','data_folder','trial','n_skel']

# List of subject folders
subj_list = [x for x in data_folder.iterdir() if x.is_dir()]

# Scan for Theia skeleton output
for subj in subj_list:
    ses_list = [x for x in subj.iterdir() if x.is_dir()]
    for ses in ses_list:
        session_admin_list.append([subj.name, ses.name])
        df_list = [x for x in ses.iterdir() if x.is_dir()]
        for df in df_list:
            trial_list = [x for x in df.iterdir() if x.is_dir()]
            for tr in trial_list:
                n_skel = len(list(tr.glob('pose_filt*.c3d')))
                trial_admin_list.append([subj.name, ses.name, df.name, tr.name, n_skel])
                
# Convert to data frame and write to Excel
session_admin = pd.DataFrame(session_admin_list, columns=col_names[0:2])
trial_admin = pd.DataFrame(trial_admin_list, columns=col_names)
# trial_admin.to_excel("admin_py.xlsx", sheet_name="trials", index=False)

with pd.ExcelWriter('admin_py.xlsx',
                    mode='a', if_sheet_exists='replace') as writer:
    session_admin.to_excel(writer, sheet_name='sessions', index=False)
    trial_admin.to_excel(writer, sheet_name='trials', index=False)
