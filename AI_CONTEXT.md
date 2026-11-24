# QuesGen — AI Context

## Project overview
QuesGen is a Flutter app for creating question papers. The current workflow lets users start a new paper, scan an image or create questions manually, edit extracted questions, and later export saved papers. The app uses a bottom navigation shell with **New Paper** and **Saved Papers** tabs.

## Tech stack
- Flutter stable on Linux ARM64 (`~/flutter`, Flutter 3.50.1 / Dart 3.14.0)
- `material_ui` for Material 3 UI
- `image_picker` for camera/gallery image selection and `image_cropper` for crop-before-scan
- `google_generative_ai` with `gemini-3.8-flash` for direct Bengali question extraction
- `http` as the Gemini SDK transport dependency
- `pdf` and `printing` for PDF generation and print/share preview
- Noto Sans Bengali fonts embedded under `assets/fonts/` for Bengali PDF text
- API key supplied with `--dart-define=GEMINI_API_KEY`; no offline OCR fallback chain

## Current progress
- Flutter project scaffolded with `lib/`, `test/`, and Android platform files.
- Bottom navigation implemented with New Paper and Saved Papers tabs.
- New Paper screen has large **Scan from Image** and **Create Manually** buttons.
- Question Editor screen supports viewing, adding, deleting, and editing question text.
- `Paper` model includes school name, exam name, class, subject, and total marks.
- Paper Details screen collects exam metadata inside the editor.
- Question Editor supports per-question marks and move up/down reordering before PDF export.
- PDF export implemented with `pdf`/`printing` and embedded Noto Sans Bengali fonts; layout includes centered exam header, Bengali question numbering, right-side marks, MCQ options (ক/খ/গ/ঘ), and page-number footer.
- Scan pipeline implemented: image pick → crop → `generateQuestionsFromImage(image: File(...))` → Gemini `DataPart('image/jpeg', bytes)` → newline-separated Bengali MCQ/short questions → Question Editor; bytes/base64 variants are also available.
- Gemini service splits non-empty response lines into questions and throws Bengali messages for API/key errors.
- Android manifest includes camera and media permissions plus the UCrop activity.
- Saved Papers screen remains unchanged.
- `flutter pub get`, `flutter analyze`, and `flutter test` were run successfully during development.

## Next steps
- Add persistent storage for saved papers and wire Saved Papers to real data.
- Add MCQ option editing in Question Editor; PDF already formats options when present.
- Add richer question editing: options, correct answers, sections, marks, and reordering.
- Add provider configuration UI or secure key storage instead of relying only on `--dart-define`.
- Add optional prompt/config tuning for mixed Bengali and English papers.
- Verify Gemini key, cropping, and Bengali output on a real Android device.
