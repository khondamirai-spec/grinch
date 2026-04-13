# StudyFlow - GitHub Codespaces Setup

## Run StudyFlow Online (No Installation Required!)

### Method 1: GitHub Codespaces (Recommended)

#### Step 1: Push to GitHub

```bash
cd D:\GRINCAHT\studyflow
git init
git add .
git commit -m "Initial commit: StudyFlow app"
```

Then create a new repository on GitHub:
1. Go to https://github.com/new
2. Create a repository named `studyflow`
3. Copy the remote URL (e.g., `https://github.com/YOUR_USERNAME/studyflow.git`)

```bash
git remote add origin https://github.com/YOUR_USERNAME/studyflow.git
git branch -M main
git push -u origin main
```

#### Step 2: Open in Codespaces

1. Go to your GitHub repository
2. Click the **green "Code" button**
3. Click the **three dots (⋯)** next to "Create codespace on main"
4. Select **"New with options..."**
5. Choose machine type: **2-core** (free tier)
6. Click **"Create codespace"**

#### Step 3: Run the App

Once the codespace opens:

```bash
# Flutter is pre-installed
flutter pub get

# Run in web mode
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

The app will be accessible at: `https://YOUR-CODESPACE-NAME-3000.app.github.dev`

---

### Method 2: GitPod (Alternative)

#### Step 1: Create .gitpod.yml

Create a file named `.gitpod.yml` in the project root (already included).

#### Step 2: Open in GitPod

1. Go to: https://gitpod.io
2. Sign in with GitHub
3. Paste your repository URL
4. Click "New Workspace"

GitPod will automatically:
- Install Flutter
- Run `flutter pub get`
- Start the development server

---

### Method 3: Project IDX (Google's Online IDE)

1. Go to: https://idx.dev
2. Sign in with Google
3. Create new project → Import from GitHub
4. Select your studyflow repository
5. IDX will auto-detect Flutter and set up the environment

---

## Quick Commands (Once in Codespace)

```bash
# Install dependencies
flutter pub get

# Run in browser (hot reload enabled)
flutter run -d chrome

# OR run on web server
flutter run -d web-server --web-port 3000

# Build for production
flutter build web --release --web-renderer canvaskit

# Check Flutter setup
flutter doctor
```

---

## Troubleshooting in Codespaces

### "No devices found"
```bash
flutter devices
# Should show "Chrome" or "Web Server"
flutter run -d web-server
```

### "Port already in use"
```bash
flutter run -d web-server --web-port 8080
```

### "Flutter not found"
```bash
export PATH="$PATH:/usr/local/flutter/bin"
flutter doctor
```

---

## Free Tier Limits

- **GitHub Codespaces:** 60 hours/month free (2-core machine)
- **GitPod:** 50 hours/month free
- **Project IDX:** Free during beta

You won't be charged unless you exceed these limits.

---

## What You'll See

Once running, you'll get a URL like:
```
https://octo-enigma-g4w6q3j5x7r9vpq-3000.app.github.dev
```

Open that in your browser and you'll see StudyFlow running! 🎉
