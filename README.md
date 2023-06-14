# MarkerlessTools
Scripts for conversion of Theia pose C3D output to QTM .mat and .tsv formats and extraction of meta data about the video data and Theia processing times.

The scripts also produce an Excel file *admin.xlsx* with an overview of the processed trials and poses. The batch processing is controlled through the *trials* tab.

## Data conversion
Main script for data conversion: markerless_data_conversion_main_script.m

The first step creates a project admin file *admin.xlsx* in the project root.
This file can be edited to select the trials that are processed in the next step.

The second step converts the Theia C3D output to QTM-like Matlab export (skeleton data).

Optionally, the third step converts the latter to QTM-like TSV export (skeleton data).

For detailed information, see the comments in the script.

## Collection of meta data about processing
Main script: markerless_meta_data_main_script.m

Extraction of the video data requires ffmpeg.

For detailed information, see commments in the script.

## Dependencies
Use of these tools requires:
- [QTMTools](https://github.com/schoondw/QTMTools)
- [ffmpeg](https://ffmpeg.org/download.html) (Optional)
