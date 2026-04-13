@echo off
echo ============================================
echo   StudyFlow - Auto Deploy to GitHub Pages
echo ============================================
echo.
echo This will:
echo 1. Add the deployment workflow
echo 2. Commit and push to GitHub
echo 3. GitHub will automatically build and deploy!
echo.

cd /d "%~dp0"

echo Step 1: Adding workflow files...
git add .
echo.

echo Step 2: Committing changes...
git commit -m "Add GitHub Actions deployment workflow"
echo.

echo Step 3: Pushing to GitHub...
git push
echo.

echo ============================================
echo   SUCCESS! 
echo ============================================
echo.
echo GitHub is now building your app!
echo.
echo To enable GitHub Pages:
echo 1. Go to: https://github.com/khondamirai-spec/grinch/settings/pages
echo 2. Source: Select "GitHub Actions"
echo 3. Wait 2-3 minutes for deployment
echo.
echo Your app will be live at:
echo https://khondamirai-spec.github.io/grinch/
echo.
pause
