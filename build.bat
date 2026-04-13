@echo off
chcp 65001 > nul
echo ============================================================
echo   Video Subtitle Extractor - Build EXE
echo   Su dung system Python (paddle duoc cai o day)
echo ============================================================
echo.

cd /d "%~dp0"

echo [1/4] Kiem tra moi truong...
python --version 2>nul
if errorlevel 1 (
    echo [LOI] Khong tim thay Python. Hay cai dat Python 3.12 truoc.
    pause
    exit /b 1
)

python -c "import paddle" 2>nul
if errorlevel 1 (
    echo [LOI] Khong tim thay paddle. Hay cai dat paddlepaddle-gpu truoc.
    pause
    exit /b 1
)

python -c "import PyInstaller" 2>nul
if errorlevel 1 (
    echo Cai dat PyInstaller vao system Python...
    pip install pyinstaller
)

echo.
echo [2/4] Dung cac process dang chay...
taskkill /F /IM VideoSubtitleExtractor.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo.
echo [3/4] Bat dau build (co the mat 10-20 phut, output ~3 GB)...
echo     Output: dist\VideoSubtitleExtractor\
echo     LUU Y: Khong mo Windows Explorer vao thu muc dist trong khi build!
echo.
set PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK=True
python -m PyInstaller gui.spec --noconfirm --clean

if errorlevel 1 (
    echo.
    echo [LOI] Build that bai.
    echo Neu loi la "The process cannot access the file", hay:
    echo  1. Dong tat ca cua so Windows Explorer dang mo thu muc dist\
    echo  2. Chay lai build.bat
    pause
    exit /b 1
)

echo.
echo [4/4] Sao chep file config...
if not exist "dist\VideoSubtitleExtractor\config" mkdir "dist\VideoSubtitleExtractor\config"
if exist "config\config.json" (
    copy /y "config\config.json" "dist\VideoSubtitleExtractor\config\config.json" > nul
)

echo.
echo ============================================================
echo   BUILD THANH CONG!
echo   Thu muc xuat: dist\VideoSubtitleExtractor\
echo   Chay app:     dist\VideoSubtitleExtractor\VideoSubtitleExtractor.exe
echo ============================================================
echo.
pause
