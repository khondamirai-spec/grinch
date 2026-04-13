# StudyFlow Deployment Guide

## Prerequisites

1. Install Flutter SDK (3.0.0+)
2. Enable web development:
   ```bash
   flutter config --enable-web
   ```

## Local Development

### Install Dependencies
```bash
cd studyflow
flutter pub get
```

### Run in Chrome
```bash
flutter run -d chrome
```

### Run in Debug Mode
```bash
flutter run -d chrome --debug
```

## Production Build

### Build for Web
```bash
flutter build web --release --web-renderer canvaskit
```

The output will be in `build/web/`

### Test Production Build Locally
```bash
# Install a simple HTTP server
pub global activate dhttpd

# Run the server
pub global run dhttpd --path build/web
```

Or use Python:
```bash
cd build/web
python -m http.server 8000
```

Then open `http://localhost:8000` in your browser.

## Deploy to Vercel

### Option 1: Vercel CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Navigate to build folder
cd build/web

# Deploy
vercel --prod
```

### Option 2: Vercel Dashboard (Recommended)

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project"
4. Import your `studyflow` repository
5. Configure build settings:

   **Framework Preset:** Other
   
   **Build Command:**
   ```
   flutter build web --release --web-renderer canvaskit
   ```
   
   **Output Directory:**
   ```
   build/web
   ```
   
   **Install Command:**
   ```
   flutter pub get
   ```

6. Click "Deploy"

### Option 3: Static Deployment

1. Build locally:
   ```bash
   flutter build web --release --web-renderer canvaskit
   ```

2. Create a new repository for the build output
3. Push `build/web` contents to the repository
4. Import in Vercel as a static site

## Vercel Configuration

The `vercel.json` file is included in the project root. This ensures:
- Client-side routing works correctly
- Direct URL access works
- Page refresh doesn't 404

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

## Custom Domain (Optional)

1. Go to your Vercel project
2. Navigate to Settings > Domains
3. Add your custom domain
4. Update DNS records as instructed

## Environment Variables

StudyFlow doesn't require any environment variables for local-first operation.

If you add cloud sync in the future, you can configure them in:
- Vercel Dashboard > Settings > Environment Variables

## Performance Optimization

The app is already optimized with:
- CanvasKit renderer for better performance
- Lazy loading of resources
- Efficient state management with Riverpod

## Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

### Storage Issues in Browser
- Clear browser data
- Check IndexedDB storage limits
- Large files (>50MB) are rejected

### Audio Doesn't Play
- Check browser autoplay settings
- Ensure file format is supported (mp3, wav, ogg)

## Browser Support

- Chrome/Edge (recommended)
- Firefox
- Safari
- Opera

## Storage Limits

- IndexedDB varies by browser (typically 50MB+)
- File size limit: 50MB per file
- Recommended: Keep files under 10MB for best performance

## Updates

To update the deployed version:
1. Make your changes
2. Commit and push to GitHub
3. Vercel will auto-deploy (if connected)
4. Or manually run `vercel --prod`

## Monitoring

Check your Vercel dashboard for:
- Deployment status
- Analytics
- Performance metrics
- Error logs
