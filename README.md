# MarkerlessTools
Scripts for conversion of Theia pose C3D output to QTM .mat and .tsv formats and extraction of meta data about the video data and Theia processing times.

The scripts also produce an Excel file *admin.xlsx* with an overview of the processed trials and poses. The batch processing is controlled through the *trials* tab.

## Data conversion
Main script for data conversion: markerless_data_conversion_main_script.m

The second step in this script requires Visual3D software for parsing the 4x4 Rotation data in the Theia C3D output.

For detailed information, see the comments in the script.

## Collection of meta data about processing
Main script: markerless_meta_data_main_script.m

Extraction of the video data requires ffmpeg.

For detailed information, see commments in the script.

## Dependencies
Use of these tools requires:
- [QTMTools](https://github.com/schoondw/QTMTools)
- [Visual3D](https://c-motion.com/index.php#visual3d)
- [ffmpeg](https://ffmpeg.org/download.html) (Optional)
