@echo off
echo ============================================
echo   StudyFlow - Push to GitHub
echo ============================================
echo.

cd /d "%~dp0"

echo Step 1: Initializing Git repository...
git init
echo.

echo Step 2: Adding all files...
git add .
echo.

echo Step 3: Creating initial commit...
git commit -m "Initial commit: StudyFlow student task manager"
echo.

echo Step 4: Setting main branch...
git branch -M main
echo.

echo ============================================
echo   Next Steps:
echo ============================================
echo.
echo 1. Create a new repository on GitHub:
echo    - Go to: https://github.com/new
echo    - Repository name: studyflow
echo    - Leave everything else default
echo    - Click "Create repository"
echo.
echo 2. Copy the repository URL shown on GitHub
echo.
echo 3. Run this command (replace YOUR_USERNAME):
echo    git remote add origin https://github.com/YOUR_USERNAME/studyflow.git
echo    git push -u origin main
echo.
echo 4. Open in Codespaces:
echo    - Go to your GitHub repo
echo    - Click "Code" button
echo    - Click "..." ^> "New with options..."
echo    - Create codespace and run:
echo      flutter run -d web-server --web-port 3000
echo.
pause
