# QuesGen — AI Context

## Project overview
QuesGen is a Flutter app for creating question papers. The current workflow lets users start a new paper, scan an image or create questions manually, edit extracted questions, and later export saved papers. The app uses a bottom navigation shell with **New Paper** and **Saved Papers** tabs.

## Tech stack
- Flutter stable on Linux ARM64 (`~/flutter`, Flutter 3.50.1 / Dart 3.14.0)
- `material_ui` for Material 3 UI
- `image_picker` for camera/gallery image selection
- `google_mlkit_text_recognition` for offline OCR fallback
- `http` for cloud OCR provider calls
- Cloud OCR providers: Gemini (`GEMINI_API_KEY`, optional `GEMINI_MODEL`) and OpenAI (`OPENAI_API_KEY`, optional `OPENAI_MODEL`)
- OCR fallback order: Gemini → OpenAI → ML Kit

## Current progress
- Flutter project scaffolded with `lib/`, `test/`, and Android platform files.
- Bottom navigation implemented with New Paper and Saved Papers tabs.
- New Paper screen has large **Scan from Image** and **Create Manually** buttons.
- Question Editor screen supports viewing, adding, deleting, and editing question text.
- OCR pipeline implemented: image pick → cloud OCR providers → ML Kit fallback → regex question extraction → Question Editor.
- Question extractor handles ASCII numbering, Bengali digits, and Bengali letter markers.
- Android manifest includes camera and media permissions.
- Fallback OCR strategy implemented behind `OcrService` with provider abstraction.
- `flutter pub get`, `flutter analyze`, and `flutter test` were run successfully during development.

## Next steps
- Add persistent storage for saved papers and wire Saved Papers to real data.
- Add PDF export using `features/pdf_export`.
- Add richer question editing: options, correct answers, sections, marks, and reordering.
- Add provider configuration UI or secure key storage instead of relying only on `--dart-define`.
- Add OCR result confidence handling and better extraction heuristics for Bengali/English mixed papers.
- Add platform builds/tests for Android and verify ML Kit behavior on a real device.
