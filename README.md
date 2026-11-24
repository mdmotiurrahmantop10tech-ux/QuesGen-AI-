# QuesGen

QuesGen is a Flutter app for creating exam question papers. It supports scanning images for questions, manual question editing, paper metadata entry, and PDF export with Bengali font support.

## Features

- Bottom navigation with **New Paper** and **Saved Papers**.
- **Scan from Image** using camera or gallery.
- OCR pipeline: Gemini cloud OCR first, ML Kit offline fallback.
- Regex question extraction for ASCII, Bengali digits, and Bengali letter markers.
- Question editor with editable text, per-question marks, and move up/down ordering.
- Paper details: school name, exam name, class, subject, and total marks.
- PDF export using `pdf` + `printing` with embedded Noto Sans Bengali fonts.

## Repository layout

```text
lib/
  core/theme/          App theme
  models/              Paper and Question models
  features/capture/    New Paper and Saved Papers screens
  features/ocr/        OCR providers, fallback service, question extractor
  features/editor/     Question editor screen
  features/pdf_export/ Paper details screen and PDF export service
.github/workflows/     GitHub Actions APK build
assets/fonts/          Noto Sans Bengali fonts
```

## Build the APK with GitHub Actions

The workflow `.github/workflows/build_apk.yml` builds a release APK on every push to `main` and also supports manual runs.

### 1. Create the GitHub repository

Create a new **empty** repository on GitHub. Do not initialize it with a README, `.gitignore`, or license because this project already has them.

### 2. Add the Gemini API key secret

The app reads the Gemini key from `--dart-define=GEMINI_API_KEY`. In CI this value comes from a GitHub Actions secret.

1. Open Google AI Studio and create an API key.
2. In your GitHub repository, go to **Settings → Secrets and variables → Actions → New repository secret**.
3. Name it exactly:

```text
GEMINI_API_KEY
```

4. Paste the API key as the value.

If the secret is missing or empty, the app skips Gemini and uses the offline ML Kit OCR fallback.

### 3. Push the code from a mobile terminal

On the phone, open your terminal app and install Git if needed:

```bash
pkg install git
```

Then run:

```bash
cd /path/to/QuesGen
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

If the repository already has a remote configured, use:

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

For HTTPS pushes, GitHub may ask for credentials. Use your GitHub username and a personal access token as the password if you have two-factor authentication enabled.

### 4. Download the APK

1. Open the repository on GitHub.
2. Go to the **Actions** tab.
3. Select the **Build APK** workflow.
4. Open the latest successful run for your `main` push.
5. Scroll to the bottom and download the artifact named:

```text
quesgen-release-apk
```

6. Extract the ZIP. Inside is `app-release.apk`.
7. Transfer `app-release.apk` to the Android phone and install it. Android may ask you to allow installs from the file manager or browser.

### 5. Rebuild manually

To rebuild without pushing new code:

1. Go to **Actions → Build APK**.
2. Click **Run workflow**.
3. Wait for completion, then download the artifact again.

If you add or change `GEMINI_API_KEY` later, rerun the workflow or push a new commit so the APK is rebuilt with the secret.

## Local development

Flutter is required for local analysis and tests:

```bash
flutter pub get
flutter analyze
flutter test
```

To build locally with the Gemini key:

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
```

The generated APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Notes

- The default Gemini model is configured in `lib/features/ocr/gemini_ocr_provider.dart`.
- The offline OCR fallback uses `google_mlkit_text_recognition`.
- Bengali PDF rendering uses the embedded Noto Sans Bengali fonts in `assets/fonts/`.
