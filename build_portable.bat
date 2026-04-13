@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul
echo ============================================================
echo   Video Subtitle Extractor - Build Portable (KHONG PyInstaller)
echo   Copy Python runtime + packages -> khong bao gio bi loi import
echo ============================================================
echo.

cd /d "%~dp0"

set PYTHON_SRC=C:\Users\Admin\AppData\Local\Programs\Python\Python312
set OUT=dist\VideoSubtitleExtractor
set SP=%PYTHON_SRC%\Lib\site-packages

echo [1/6] Kiem tra moi truong...
if not exist "%PYTHON_SRC%\python.exe" (
    echo [LOI] Khong tim thay Python tai: %PYTHON_SRC%
    pause & exit /b 1
)
python --version

echo.
echo [2/6] Dung process cu va tao thu muc output...
taskkill /F /IM VideoSubtitleExtractor.exe >nul 2>&1
timeout /t 2 /nobreak >nul
if exist "%OUT%" rmdir /S /Q "%OUT%" >nul 2>&1
mkdir "%OUT%"
mkdir "%OUT%\_python"

echo.
echo [3/6] Copy Python runtime (exe + DLLs + stdlib)...
copy /Y "%PYTHON_SRC%\python.exe"        "%OUT%\_python\" >nul
copy /Y "%PYTHON_SRC%\python3.dll"       "%OUT%\_python\" >nul 2>&1
copy /Y "%PYTHON_SRC%\python312.dll"     "%OUT%\_python\" >nul
copy /Y "%PYTHON_SRC%\vcruntime140.dll"  "%OUT%\_python\" >nul 2>&1
copy /Y "%PYTHON_SRC%\vcruntime140_1.dll" "%OUT%\_python\" >nul 2>&1
xcopy /E /I /Q /Y "%PYTHON_SRC%\DLLs"   "%OUT%\_python\DLLs" >nul
echo    stdlib (co the mat vai phut)...
xcopy /E /I /Q /Y "%PYTHON_SRC%\Lib"    "%OUT%\_python\Lib" /EXCLUDE:build_exclude_dirs.txt >nul

echo.
echo [4/6] Copy site-packages (bo qua torch, nvidia, llama_cpp...)...
REM Packages khong can - bo qua de giam kich thuoc
set SKIP_PKGS=torch torchvision torchaudio nvidia llama_cpp playwright nuitka PyQt5 PyQt6

for /D %%d in ("%SP%\*") do (
    set "skip=0"
    for %%s in (%SKIP_PKGS%) do (
        echo %%~nd | findstr /I /B "%%s" >nul && set "skip=1"
    )
    if "!skip!"=="0" (
        xcopy /E /I /Q /Y "%%d" "%OUT%\_python\Lib\site-packages\%%~nd" >nul
    )
)
REM Copy single-file .py packages (soundfile, etc.)
for %%f in ("%SP%\*.py") do (
    copy /Y "%%f" "%OUT%\_python\Lib\site-packages\" >nul 2>&1
)
REM Copy numpy.libs (OpenBLAS DLLs critical for numpy)
if exist "%SP%\numpy.libs" (
    xcopy /E /I /Q /Y "%SP%\numpy.libs" "%OUT%\_python\Lib\site-packages\numpy.libs" >nul
)

echo.
echo [5/6] Copy project files...
xcopy /E /I /Q /Y "backend"    "%OUT%\backend" >nul
xcopy /E /I /Q /Y "ui"        "%OUT%\ui" >nul
xcopy /E /I /Q /Y "config"    "%OUT%\config" >nul
xcopy /E /I /Q /Y "design"    "%OUT%\design" >nul
copy /Y "gui.py" "%OUT%\" >nul

echo.
echo [6/6] Build launcher EXE (tiny, chi dung stdlib)...
python -m PyInstaller launcher.spec --noconfirm --clean --distpath "%OUT%" >nul 2>&1
if errorlevel 1 (
    echo [CANH BAO] Khong build duoc launcher EXE, tao file bat thay the...
    echo @echo off > "%OUT%\VideoSubtitleExtractor.bat"
    echo set PYTHONHOME=%%~dp0_python >> "%OUT%\VideoSubtitleExtractor.bat"
    echo set PYTHONPATH=%%~dp0_python\Lib\site-packages >> "%OUT%\VideoSubtitleExtractor.bat"
    echo set PATH=%%~dp0_python;%%~dp0_python\DLLs;%%~dp0_python\Lib\site-packages\numpy.libs;%%PATH%% >> "%OUT%\VideoSubtitleExtractor.bat"
    echo start "" /B "%%~dp0_python\python.exe" "%%~dp0gui.py" >> "%OUT%\VideoSubtitleExtractor.bat"
)

echo.
echo ============================================================
echo   BUILD PORTABLE THANH CONG!
echo   Thu muc: %OUT%\
echo   Chay:    %OUT%\VideoSubtitleExtractor.exe
echo            (hoac VideoSubtitleExtractor.bat neu khong co exe)
echo ============================================================
echo.
echo LUU Y: Neu copy sang may khac, copy TOAN BO thu muc %OUT%\
echo        May dich khong can cai Python!
echo.
pause
