# MarkerlessTools

Scripts for batch processing of Theia3D markerless sessions collected in QTM, and conversion
of Theia pose data to QTM-like export formats.

## Theia batch processing (Python)

Scripts for batch (re)processing a whole project or selected sessions with Theia3D software.

For detailed instructions, see *py_theia_batch\Theia batch processing instructions.md*.

## Theia pose conversion (Matlab)

### Data conversion
Main script for data conversion: *markerless_data_conversion_main_script.m*

The first step creates a project admin file *admin.xlsx* in the project root.
This file can be edited to select the trials that are processed in the next step.

The second step converts the Theia C3D output to QTM-like Matlab export (skeleton data).

Optionally, the third step converts the latter to QTM-like TSV export (skeleton data).

For detailed information, see the comments in the script.

### Collection of meta data about processing
Main script: markerless_meta_data_main_script.m

Extraction of the video data requires ffmpeg.

For detailed information, see comments in the script.

### Dependencies
Use of these tools requires:
- [QTMTools](https://github.com/schoondw/QTMTools)
- [ffmpeg](https://ffmpeg.org/download.html) (required for processing of video meta data)
