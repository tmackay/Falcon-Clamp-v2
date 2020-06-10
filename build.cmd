@echo off
start "ring" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=1" -o "Falcon_Clamp_v2-ring.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
pause
start "knob" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=2" -o "Falcon_Clamp_v2-knob.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
start "planet1" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=3" -o "Falcon_Clamp_v2-planet1.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
start "planet2" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=4" -o "Falcon_Clamp_v2-planet2.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
pause
start "planet3" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=5" -o "Falcon_Clamp_v2-planet3.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
start "planet4" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=6" -o "Falcon_Clamp_v2-planet4.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
start "planet5" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=7" -o "Falcon_Clamp_v2-planet5.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
rem start "planet6" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=8" -o "Falcon_Clamp_v2-planet6.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
rem start "planet7" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=9" -o "Falcon_Clamp_v2-planet7.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
rem start "planet8" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=10" -o "Falcon_Clamp_v2-planet8.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
rem start "planet9" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=11" -o "Falcon_Clamp_v2-planet9.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
rem start "planet10" /low "c:\Program Files\OpenSCAD\openscad.exe" -D "g=12" -o "Falcon_Clamp_v2-planet10.stl" "Falcon_Clamp_v2.scad" > NUL 2>&1
pause
for %%f in ("Falcon_Clamp_v2-*.stl") do "C:\Program Files\VCG\MeshLab\meshlabserver.exe" -i %%f -o %%f
setlocal EnableDelayedExpansion
set i=
for %%f in ("Falcon_Clamp_v2-*.stl") do call set i=!i! "%%f"
"C:\Program Files\VCG\MeshLab\meshlabserver.exe" -i%i% -o Falcon_Clamp_v2.stl -s merge.mlx