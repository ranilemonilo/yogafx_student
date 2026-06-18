# Mobile Project Context Report

## 1. Project overview

### Project name
- `yogafx_student`
- Declared in `pubspec.yaml` as `YogaFX Student Mobile App`.

### Application goal
- Student-facing mobile app untuk konsumsi materi belajar YogaFX.
- Fokus utama saat ini: login, lihat dashboard, buka module/lesson, akses media lesson, assessment, assignment, ebooks, courses, certificate, dan profile.

### Supported user roles
- Hanya terlihat ada role `student`.
- Semua flow auth, dashboard, profile, dan learning domain mengarah ke student portal.
- Tidak ada indikasi role admin/instructor di app mobile ini.

### Current implementation status
- Fondasi aplikasi mobile sudah ada dan cukup luas di level UI + repository.
- Banyak screen sudah benar-benar terhubung ke backend lewat `Dio`.
- Source of truth utama sudah diarahkan ke backend untuk auth, dashboard, module, lesson, assessment, assignment, ebook, course, certificate, profile, dan dialog.
- Namun implementasi belum rapi/selesai penuh:
  - base URL masih hardcoded lokal di `lib/core/api/api_client.dart`
  - ada flow yang bersifat parsial atau presentational-only
  - ada hasil analyzer yang menunjukkan test broken dan banyak warning model/codegen
  - beberapa navigasi dan pemetaan data masih rawan mismatch dengan backend

## 2. Tech stack

| Area | Actual stack in repo |
| --- | --- |
| Main framework | Flutter (`lib/main.dart`) |
| State management | Riverpod klasik via `flutter_riverpod`; banyak `FutureProvider`, `StateNotifierProvider`, `StateNotifierProvider.family` |
| Routing | `go_router` dengan `ShellRoute` di `lib/core/router/app_router.dart` |
| Networking | `dio` + `pretty_dio_logger` via `lib/core/api/api_client.dart` |
| Auth token storage | `flutter_secure_storage` via `lib/core/storage/secure_storage.dart` |
| Local persistence | Hanya secure storage untuk token; tidak ada cache/data store lokal lain yang aktif |
| Video | `video_player` + `chewie` |
| Audio | `just_audio` |
| PDF/workbook | `flutter_pdfview`, `path_provider` |
| File upload | `file_picker` |
| External link opening | `url_launcher` |
| Image loading | `Image.network` + wrapper `AuthNetworkImage`; `cached_network_image` ada di dependency tapi praktis tidak dipakai pada screen yang diaudit |
| Model generation | `freezed`, `json_serializable`, `freezed_annotation`, `json_annotation` |
| Theming | custom dark theme di `lib/core/theme/app_theme.dart` |

### Important packages actively used
- `go_router`
- `flutter_riverpod`
- `dio`
- `flutter_secure_storage`
- `chewie`
- `video_player`
- `just_audio`
- `flutter_pdfview`
- `file_picker`
- `url_launcher`

## 3. Project structure

### Main folder structure
- `lib/main.dart`
  - entry point app.
- `lib/core/`
  - shared infrastructure: router, shell, theme, api, error, storage, shared widgets.
- `lib/features/`
  - feature-based modules per domain.
- `assets/`
  - logo and fonts.
- `test/`
  - masih menyimpan default widget test lama yang sudah tidak cocok dengan app saat ini.

### Important folders and their function
- `lib/core/api/`
  - `api_client.dart`, `api_response.dart`; pembentukan `Dio`, base URL, auth header injection, error normalization.
- `lib/core/router/`
  - `app_router.dart`; semua route app.
- `lib/core/shell/`
  - `main_shell.dart`; bottom navigation shell untuk route utama.
- `lib/core/storage/`
  - `secure_storage.dart`; simpan token auth.
- `lib/core/widgets/`
  - widget shared seperti `AuthNetworkImage` dan `RunningLoginTimeCard`.
- `lib/features/<domain>/data/`
  - models + repositories per feature.
- `lib/features/<domain>/presentation/`
  - providers dan screens per feature.

### App entry point
- `lib/main.dart`
  - `main()`
  - `YogaFXApp`

### Main shell / primary navigation
- `lib/core/shell/main_shell.dart`
- `ShellRoute` membungkus:
  - `/dashboard`
  - `/modules`
  - `/ebooks`
  - `/courses`
  - `/profile`
- Bottom navigation berisi 5 tab:
  - Home
  - Modules
  - Ebooks
  - Courses
  - Profile

## 4. Current implemented features

### Features that are clearly implemented and wired to backend
- Login, logout, session restore
- Dashboard fetch
- Module list + module detail
- Lesson detail fetch
- Video playback pada lesson
- Audio playback pada lesson
- Workbook open/download flow pada lesson
- Assessment intro/start/attempt answer/back
- Assignment detail + upload video
- Ebook list + ebook detail
- Course list + course detail
- Certificate list + certificate detail
- Profile fetch + update + change password
- Dialog list + dialog detail

### Features that work but are still partial
- Lesson progress update
  - hanya dipost dari listener video per kelipatan 5% di `LessonRepository.updateProgress()`
  - tidak terlihat update progress untuk audio/content/workbook.
- Forgot password / reset password
  - endpoint ada dan form ada, tetapi UX masih sangat basic.
- Overall progress
  - screen ada, tapi bukan hasil fetch mandiri; hanya menerima `state.extra`.
- Certificate, ebook, course, assignment open/download
  - bergantung pada URL backend yang dikirim; tidak ada normalisasi URL relatif seperti di dashboard/module/lesson.

### Features that are partial/mock/static
- `AssessmentResultScreen`
  - saat ini hanya layar presentasional statis.
  - route menerima `lessonId` dan `attemptId`, tetapi screen tidak memanggil `AssessmentRepository.getResult()`.
- `RunningLoginTimeCard`
  - dipakai luas sebagai elemen UI tambahan; bukan bagian source of truth learning.
- Beberapa screen form seperti edit profile, forgot/reset password, change password
  - functional, tapi masih utilitarian dan belum punya handling state/error yang matang.

### Features that look broken or risky
- `test/widget_test.dart`
  - masih memanggil `MyApp`, padahal app sekarang memakai `YogaFXApp`; analyzer menghasilkan error.
- Dialog route mapping
  - `DialogListScreen` mengubah key backend ke `full-standing` / `full-floor`, lalu `DialogDetailScreen` memakai key route itu langsung untuk fetch detail; ini berpotensi 404 jika backend sebenarnya memakai key asli `full_standing` / key lain.
- Auth/base URL environment
  - app tidak punya env config yang aman; repo akan gagal dipakai tim lain tanpa edit manual `ApiClient`.

## 5. API integration

### Base URL / env config pattern
- Seluruh request dibangun dari `ApiClient.create()` di `lib/core/api/api_client.dart`.
- Base URL saat ini:
  - `http://10.199.99.177:8000/api/mobile/v1`
- Ada komentar alternatif emulator:
  - `http://10.0.2.2:8000/api/mobile/v1`
- Belum ada `.env`, flavor, dart-define, atau config injection. Jadi pattern environment saat ini masih manual edit source.

### Endpoint construction pattern
- Repository memanggil endpoint relatif dari root `/api/mobile/v1`.
- Contoh:
  - `/auth/login`
  - `/dashboard`
  - `/modules`
  - `/lessons/{id}`
- `ApiClient.resolveUrl()` dipakai untuk mengubah path relatif menjadi absolute URL, tetapi saat ini hanya dipakai di:
  - `DashboardRepository`
  - `ModuleRepository`
  - `LessonRepository`
- `CourseRepository`, `EbookRepository`, `CertificateRepository`, dan `AssignmentRepository` tidak menormalisasi URL relatif.

### Auth flow
- Token disimpan di `SecureStorageService`.
- `ApiClient` menambahkan header `Authorization: Bearer <token>` via interceptor.
- `AuthNotifier._init()`:
  - cek token di secure storage
  - jika ada, call `/me`
  - jika unauthorized, token dihapus dan state jadi unauthenticated
- Redirect auth di `app_router.dart`:
  - public route: `/login`, `/forgot-password`, `/reset-password`
  - route lain butuh authenticated state

### Main endpoints currently used

| Domain | Endpoints in repo |
| --- | --- |
| Auth | `POST /auth/login`, `POST /auth/logout`, `POST /auth/forgot-password`, `POST /auth/reset-password`, `GET /me` |
| Dashboard | `GET /dashboard` |
| Modules | `GET /modules`, `GET /modules/{moduleId}` |
| Lessons | `GET /lessons/{lessonId}`, `POST /lessons/{lessonId}/progress` |
| Assessment | `GET /lessons/{lessonId}/assessment`, `POST /lessons/{lessonId}/assessment/start`, `GET /lessons/{lessonId}/assessment/attempts/{attemptId}`, `POST /lessons/{lessonId}/assessment/attempts/{attemptId}/answer`, `POST /lessons/{lessonId}/assessment/attempts/{attemptId}/back`, `GET /lessons/{lessonId}/assessment/attempts/{attemptId}/result` |
| Assignment | `GET /assignments/{assignmentId}`, `POST /assignments/{assignmentId}/submit` |
| Ebook | `GET /ebooks`, `GET /ebooks/{ebookId}` |
| Course | `GET /courses`, `GET /courses/{courseId}` |
| Certificate | `GET /certificates`, `GET /certificates/{certificateId}` |
| Profile | `GET /profile`, `PATCH /profile`, `POST /profile/change-password` |
| Dialog | `GET /dialogs`, `GET /dialogs/{key}` |

### Active repository/service layer
- `AuthRepository`
- `DashboardRepository`
- `ModuleRepository`
- `LessonRepository`
- `AssessmentRepository`
- `AssignmentRepository`
- `EbookRepository`
- `CourseRepository`
- `CertificateRepository`
- `ProfileRepository`
- `DialogRepository`

## 6. Navigation map

### Main screens and relationships
- `/login`
  - links ke `/forgot-password` dan `/reset-password`
  - sukses login ke `/dashboard`
- `/dashboard`
  - ke `/dialogs`
  - ke `/profile`
  - ke `/modules`
  - ke `/lessons/:lessonId`
  - ke `/overall-progress` via `extra`
- `/modules`
  - ke `/modules/:moduleId`
- `/modules/:moduleId`
  - ke `/lessons/:lessonId`
- `/lessons/:lessonId`
  - ke `/lessons/:lessonId/assessment`
  - ke `/assignments/:assignmentId`
  - ke `/workbook-viewer`
  - ke lesson lain via `pushReplacement`
- `/lessons/:lessonId/assessment`
  - start/continue ke `/lessons/:lessonId/assessment/attempts/:attemptId`
- `/lessons/:lessonId/assessment/attempts/:attemptId`
  - selesai diarahkan ke `/lessons/:lessonId/assessment/attempts/:attemptId/result`
- `/ebooks`
  - ke `/ebooks/:ebookId`
- `/courses`
  - ke `/courses/:courseId`
- `/profile`
  - ke `/profile/edit`
  - ke `/profile/change-password`
  - ke `/certificates`
- `/certificates`
  - ke `/certificates/:certificateId`
- `/dialogs`
  - ke `/dialogs/:dialogKey`

### Route/shell mechanics
- `ShellRoute` hanya untuk tab utama.
- Route seperti certificate, dialog, lesson, assessment, assignment berada di luar shell, jadi bottom nav tidak selalu tampil.
- `initialLocation` diarahkan ke `/dashboard`, lalu redirect auth memaksa login jika belum authenticated.

### Routing bugs / oddities
- `/overall-progress`
  - memaksa `state.extra! as Map<String, int>`; jika screen dibuka tanpa `extra`, akan crash.
- `/workbook-viewer`
  - memaksa `state.extra! as Map<String, String>`; juga rawan crash jika extra tidak lengkap.
- `DialogListScreen` melakukan translasi key yang terlalu sempit:
  - `full_standing -> full-standing`
  - selain itu semua jadi `full-floor`
  - ini bisa salah route untuk item dialog lain.
- `MainShell._selectedIndex()`
  - hanya mengenali empat path shell + default dashboard; route luar shell memang tidak di-handle.

## 7. Feature-by-feature audit

| Domain | Status | Main files | Findings | Backend dependency |
| --- | --- | --- | --- | --- |
| Auth | `partial` | `lib/features/auth/data/repositories/auth_repository.dart`, `lib/features/auth/presentation/providers/auth_provider.dart`, `lib/features/auth/presentation/screens/login_screen.dart`, `forgot_password_screen.dart`, `reset_password_screen.dart` | Login/logout/session restore wired. Forgot/reset tersedia tapi UX sangat basic. Error message masih `e.toString()`. Base URL hardcoded membuat auth tidak portable. | `POST /auth/login`, `POST /auth/logout`, `POST /auth/forgot-password`, `POST /auth/reset-password`, `GET /me` |
| Dashboard/home | `done` | `lib/features/dashboard/data/repositories/dashboard_repository.dart`, `lib/features/dashboard/presentation/screens/dashboard_screen.dart` | Sudah fetch backend dan render section dinamis. Thumbnail URL dinormalisasi. Banyak CTA menuju feature lain. | `GET /dashboard` |
| Modules | `done` | `lib/features/module/data/repositories/module_repository.dart`, `lib/features/module/presentation/screens/module_list_screen.dart` | List module live dari backend, summary/progress ikut backend. | `GET /modules` |
| Module detail | `done` | `lib/features/module/data/repositories/module_repository.dart`, `lib/features/module/presentation/screens/module_detail_screen.dart` | Detail module live, lock state lesson dihormati, CTA play menuju first unlocked lesson. | `GET /modules/{moduleId}` |
| Lesson detail | `partial` | `lib/features/lesson/data/repositories/lesson_repository.dart`, `lib/features/lesson/presentation/screens/lesson_screen.dart` | Fetch detail, navigation, workbook, assessment banner, next lesson sudah ada. Namun progress update hanya untuk video watch progress; audio/content/workbook tidak jadi source of truth kemajuan. | `GET /lessons/{lessonId}`, `POST /lessons/{lessonId}/progress` |
| Lesson media (video/audio/workbook) | `partial` | `lesson_screen.dart`, `workbook_viewer_screen.dart` | Video via Chewie, audio via `just_audio`, workbook via PDF download lalu `PDFView`. Tidak ada caching selain file temp workbook. Error handling cukup basic. Workbook viewer mewajibkan URL valid dan route extra benar. | Bergantung pada payload URL dari `GET /lessons/{lessonId}` |
| Ebooks | `partial` | `lib/features/ebook/data/repositories/ebook_repository.dart`, `ebook_list_screen.dart`, `ebook_detail_screen.dart` | List/detail live, preview/download open via external app. Tidak ada inline preview di app. URL tidak dinormalisasi jika backend mengirim path relatif. | `GET /ebooks`, `GET /ebooks/{ebookId}` |
| Courses | `partial` | `lib/features/course/data/repositories/course_repository.dart`, `course_list_screen.dart`, `course_detail_screen.dart` | List/detail live, video playback ada. Tidak ada auth header injection khusus untuk video URL selain URL langsung. URL relatif juga tidak dinormalisasi. Tidak ada progress/reporting. | `GET /courses`, `GET /courses/{courseId}` |
| Progress | `partial` | `lib/features/dashboard/data/models/dashboard_model.dart`, `dashboard_screen.dart`, `overall_progress_screen.dart`, `lesson_repository.dart` | Dashboard menampilkan progress backend. Screen overall progress hanya presentasi dari data yang dipassing via route extra. Update progress lesson terbatas ke video. | `GET /dashboard`, `POST /lessons/{lessonId}/progress` |
| Assessment | `partial` | `lib/features/assessment/data/repositories/assessment_repository.dart`, `assessment_intro_screen.dart`, `assessment_screen.dart`, `assessment_result_screen.dart` | Intro/start/attempt answer/back sudah live. Result screen belum memakai `getResult()` walau endpoint dan repository method ada, jadi hasil assessment di UI masih statis/presentasional. | `GET/POST` seluruh endpoint assessment; `GET result` belum dipakai screen |
| Assignment | `partial` | `lib/features/assignment/data/repositories/assignment_repository.dart`, `assignment_screen.dart` | Detail dan upload video wired. UI tidak terlihat menghormati `canSubmit`/`isLocked` secara ketat; tombol upload tetap tersedia dari content screen. URL submission video dibuka di external app. Ada analyzer note soal package `http_parser` belum dideklarasikan di `pubspec.yaml`. | `GET /assignments/{assignmentId}`, `POST /assignments/{assignmentId}/submit` |
| Certificate | `partial` | `lib/features/certificate/data/repositories/certificate_repository.dart`, `certificate_list_screen.dart`, `certificate_detail_screen.dart` | List/detail dan open/download sudah ada. Detail repository mengambil `data['certificate']`, jadi sangat tergantung shape response. URL juga tidak dinormalisasi. | `GET /certificates`, `GET /certificates/{certificateId}` |
| Profile / change password | `partial` | `lib/features/profile/data/repositories/profile_repository.dart`, `profile_screen.dart`, `edit_profile_screen.dart`, `change_password_screen.dart` | Fetch/update/change password wired. Edit profile form besar tapi semua field manual text input, belum ada picker/enum handling. Setelah change password hanya tampil success text, tidak ada redirect atau token refresh logic. | `GET /profile`, `PATCH /profile`, `POST /profile/change-password` |

### Additional feature outside requested audit
- Dialogs: `partial`
  - Files: `lib/features/dialog/**`
  - Backend wired untuk list/detail.
  - Routing key transformation di `DialogListScreen` sangat rawan mismatch.

## 8. Data flow

### How screens fetch data
- Sebagian besar screen read-only memakai `FutureProvider`:
  - dashboard, module list/detail, lesson detail, ebook list/detail, course list/detail, certificate list/detail, profile, dialogs, assignment detail, assessment intro.
- Assessment play memakai `StateNotifierProvider.family` karena state attempt perlu berubah setelah submit answer / back.
- Auth memakai `StateNotifierProvider` custom `AuthNotifier`.

### How state is managed
- Tidak ada global app state kompleks selain auth.
- Fetch state umumnya one-shot per screen dengan invalidation manual:
  - `ref.invalidate(provider)` untuk refresh/retry.
- Form screen cenderung menyimpan state lokal via `StatefulWidget`, bukan via Riverpod form state.

### Whether backend is source of truth
- Ya, untuk sebagian besar domain read model.
- Tidak, atau belum penuh, untuk:
  - assessment result UI
  - progress aggregation screen (`OverallProgressScreen`) karena hanya consume route extra
  - beberapa action state seperti upload eligibility di assignment yang tidak sepenuhnya dijadikan guard di UI

### Areas still hardcoded / mock / static
- `ApiClient._baseUrl` hardcoded IP lokal.
- `AssessmentResultScreen` hardcoded status `'completed'` dan tidak memuat hasil nyata.
- `widget_test.dart` masih template default counter app.
- Dialog route key mapping hardcoded ke dua kemungkinan.

## 9. Known issues

### Important bugs / repo problems observed
- `test/widget_test.dart` broken
  - memanggil `MyApp`, padahal app sekarang `YogaFXApp`.
  - `flutter analyze` menghasilkan error: `The name 'MyApp' isn't a class`.
- Analyzer menemukan banyak warning `invalid_annotation_target`
  - terutama di model `assessment_model.dart`, `module_model.dart`, `lesson_model.dart`, `profile_model.dart`, `auth_user.dart`, `login_response.dart`.
  - Ini menandakan setup Freezed/JsonKey atau lint config belum bersih.
- `lib/features/assessment/presentation/screens/assessment_result_screen.dart`
  - tidak pakai repository `getResult()`.
  - Hasil assessment yang dilihat user kemungkinan tidak mencerminkan skor/status backend.
- `lib/features/dialog/presentation/screens/dialog_list_screen.dart`
  - `_routeKey()` hanya mendukung dua key dan default ke `full-floor`.
  - Jika backend mengirim key lain, navigasi detail hampir pasti salah.
- `lib/features/assignment/presentation/screens/assignment_screen.dart`
  - tombol upload tidak terlihat dibatasi oleh `assignment.canSubmit` atau `assignment.isLocked`; behavior final bergantung backend reject.
- `lib/core/api/api_client.dart`
  - base URL tidak reusable untuk environment lain.
  - repo ini belum siap dijalankan tim lain tanpa edit source.

### Layout / navigation / media risks
- `overall-progress` dan `workbook-viewer` akan crash jika route `extra` kosong atau shape salah.
- `AuthNetworkImage` mengambil token lewat `FutureBuilder` per widget image.
  - Berpotensi boros rebuild dan menyebabkan loading image lebih lambat pada list panjang.
- `CourseDetailScreen` dan beberapa screen media memakai `Image.network`/video URL langsung.
  - Jika backend mengirim path relatif atau butuh auth header khusus, media bisa gagal load.
- `WorkbookViewerScreen` download PDF ke temp tiap kali screen dibuka.
  - Tidak ada cleanup/caching policy.

### Refactor-sensitive areas
- `app_router.dart`
  - route tree cukup besar dan banyak path string literal di screen.
- `lesson_screen.dart`
  - file sangat besar dan menggabungkan networking side effects, media controller lifecycle, navigation, dan banyak subwidget.
- `dashboard_screen.dart`, `module_detail_screen.dart`, `assignment_screen.dart`
  - masing-masing file sudah sangat panjang dan sebaiknya dipecah jika lanjut dikembangkan.

## 10. Recommended next priorities

### Safe execution order
1. Rapikan fondasi environment dan build health.
   - Pindahkan base URL ke `--dart-define` atau config layer.
   - Betulkan `test/widget_test.dart`.
   - Bersihkan warning model/codegen yang paling mengganggu.
2. Bereskan gap paling jelas antara UI dan backend.
   - Wiring `AssessmentResultScreen` ke `AssessmentRepository.getResult()`.
   - Pastikan assignment upload CTA menghormati `canSubmit` dan `isLocked`.
   - Pastikan dialog detail memakai key backend yang benar.
3. Stabilkan URL/media handling.
   - Samakan normalisasi URL untuk course, ebook, certificate, assignment seperti dashboard/module/lesson.
   - Audit apakah media endpoint perlu auth header.
4. Kuatkan navigasi dan typed route data.
   - Hindari cast `state.extra!` tanpa guard.
   - Pertimbangkan typed object/helper untuk route extra.
5. Refactor screen besar.
   - Pecah `lesson_screen.dart`, `dashboard_screen.dart`, `assignment_screen.dart`, `module_detail_screen.dart`.

### Foundational priorities that should be fixed first
- `ApiClient` environment/config
- test/analyzer health
- assessment result real backend wiring
- dialog route key correctness
- typed/guarded navigation extras

## Verification notes
- Repo diaudit dari kode aktual di `lib/`, `pubspec.yaml`, dan `test/widget_test.dart`.
- `flutter.bat analyze` dijalankan pada tanggal 2026-06-18 dan menghasilkan:
  - 1 error nyata di `test/widget_test.dart`
  - banyak warnings `invalid_annotation_target`, unused import, dan lint issues
- Laporan ini fokus ke kondisi repo saat ini, bukan roadmap lama atau asumsi di luar source code.
