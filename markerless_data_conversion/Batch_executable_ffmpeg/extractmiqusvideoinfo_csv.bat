@echo off
set outfile=miqusvideoinfo.txt
if exist %outfile% (
	del %outfile%
)
for /R %%i in (*Miqus*.avi) do (
	echo "%%~fi" >> %outfile% & ffprobe -i "%%~fi" -v quiet -select_streams v:0 -show_entries stream=width,height,nb_frames -of csv=p=0 >> %outfile%
)
