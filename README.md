# QuesGen

QuesGen is a Flutter app for creating exam question papers. It supports scanning images for questions, manual question editing, paper metadata entry, and PDF export with Bengali font support.

## Features

- Bottom navigation with **New Paper** and **Saved Papers**.
- **Scan from Image** using camera or gallery with a crop step.
- Gemini API reads Bengali question papers directly and returns only the questions.
- No OCR library or regex extraction; Bengali error messages are shown when the API is unavailable.
- Question editor with editable text, per-question marks, and move up/down ordering.
- Paper details: school name, exam name, class, subject, and total marks.
- PDF export using `pdf` + `printing` with embedded Noto Sans Bengali fonts.

## Repository layout

```text
lib/
  core/theme/          App theme
  models/              Paper and Question models
  features/capture/    New Paper and Saved Papers screens
  services/            Gemini API question extraction
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

1. Open https://aistudio.google.com/app/apikey and sign in with a Google account.
2. Click **Get API key**, then choose **Create API key in new project** (or select an existing project).
3. Copy the generated key. Google AI Studio provides a free tier for testing.
4. In your GitHub repository, go to **Settings → Secrets and variables → Actions → New repository secret**.
5. Name it exactly:

```text
GEMINI_API_KEY
```

6. Paste the API key as the value.

If the secret is missing or empty, scanning shows a Bengali error message instead of questions.

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

To run the app locally with your own free API key:

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
```

If you see `GEMINI_API_KEY সেট করা নেই`, rerun with the command above; the key is never stored in source control.

To build locally with the same key:

```bash
flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
```

The generated APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Notes

- The Gemini model (`gemini-3.8-flash`) and Bengali prompt live in `lib/services/gemini_service.dart`.
- Images are sent as `DataPart('image/jpeg', bytes)` through `google_generative_ai`.
- `generateQuestionsFromImage({required File image, String? extraPrompt})` is the main API; `generateQuestionsFromBytes` and `generateQuestionsFromBase64` accept raw bytes or base64. The Bengali prompt asks for MCQ options (ক/খ/গ/ঘ) or short questions without extra explanation.
- Bengali PDF rendering uses the embedded Noto Sans Bengali fonts in `assets/fonts/`.
