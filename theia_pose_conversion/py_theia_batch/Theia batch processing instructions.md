# Theia batch processing with Python

These scripts will allow for batch (re)processing a whole project or selected sessions with Theia3D software.

Requirements:
- Computer with Theia3D
- QTM PAF project with markerless sessions, for example the *Theia Markerless Example*.

## Installation instructions

### Install Python environment (for example Anaconda) on computer.
Required packages:
- pathlib
- subprocess
- tqdm
- pandas
- openpyxl

### Unpack py_theia_batch.zip in QTM project folder. The folder should now contain the following files:
- create_session_admin.py
- batch_theia_process.py

### Modifications to Settings.paf.
Add the following lines under Analyses:

```
  Export Metadata:
    Type: Instantiate template
    Export session: Yes
    Template: Templates\Scripts\src\Theia\run_theia_tools.php
    Export measurements: [c3d,xml settings]
  Initiate Theia:
    Type: External program
    Program display name: Theia
    Do not wait for Application: Yes
    Arguments: [-path, $TemplateDirectory$Scripts\src\Theia\theia_batch_commands.txt, -force-single-instance]
```

Under Sessions, make sure that your markerless sessions contain the following analyses:

      Analyses: [..., Export Metadata, Initiate Theia]

## Use instructions

### In the QTM project

Make sure that the meta data for all the sessions to be processed have been exported.
If the sessions have previously been processed and if you have not made any changes to the session, the meta data should still be present.
If the meta data has not yet been exported, you can export them without further processing by using the *Export Metadata* processing option.

**Warning!** Make sure that Theia is not running, otherwise this action may initiate processing in Theia.

*Note:* To avoid the unintended start of Theia processing, you can add an empty text file *do_nothing.php* to the Templates folder
and in the *Export Metadata* settings replace

	Template: Templates\Scripts\src\Theia\run_theia_tools.php

by

	Template: do_nothing.php


### Python scripts

For running the Python scripts, open a Python terminal and set the current directory to the project directory.

The Python batch processing consists of two steps.

First, create a session administration file using the script *create_session_admin.py*.
This script will create an Excel file *admin.xlsx* with a sheet *sessions*.
If the Excel file is already present, it will add the *sessions* sheet to the existing file, overwriting the *sessions* sheet if it already exists.

The *sessions* sheet contains all detected sessions for all subjects in the project.
You can review the session administration and adapt it by manually removing or adding sessions.
This way you can make a selection of the sessions to be (re)processed.
Optionally, you can keep alternative session lists in other sheets.
The *batch_theia_process.py* script will only read from the *sessions* sheet.

After completing the session administration, you can now start the batch processing:

- To start the batch processing with Theia, open Theia from within the QTM project by using the *Initiate Theia* processing option.
- Run the script *batch_theia_process.py*.

**Warning!** Depending on the number of sessions to be reprocessed, this can take a very long time.
