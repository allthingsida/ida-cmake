@echo off

:: checkout the Batchography book

setlocal

if not defined IDASDK (
    echo IDASDK environment variable not set.
    echo Also make sure ida-cmake is installed in IDASDK.
    echo See: https://github.com/allthingsida/ida-cmake
    goto :eof
)

if not exist build cmake -A x64 -B build -S .
if not exist build64 cmake -B build64 -S . -A x64 -DEA64=YES

if "%1"=="build" cmake --build build --config Release && cmake --build build64 --config Release

echo.
echo All done!
echo.