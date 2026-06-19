# Mobile Assessment Student Flow Source of Truth

## Tujuan

Dokumen ini menjadi source of truth untuk implementasi domain assessment/scoreboard di sisi student pada aplikasi mobile.

Fokus dokumen ini:

- flow assessment student
- perilaku engine question
- navigation
- validation
- scoring
- results
- time tracking
- state resume
- contract UI/UX mobile

Dokumen ini tidak membahas builder admin secara detail, kecuali bagian yang memengaruhi perilaku student.

---

## Prinsip Umum

1. Mobile harus mengikuti engine yang sama dengan web.
2. Perilaku question, validation, jump, scoring, result, dan progress harus konsisten dengan web.
3. Perbedaan mobile hanya boleh pada presentasi UI/UX, bukan pada business rule.
4. Assessment preview admin meniru flow student, tetapi tanpa persistence.
5. Source of truth correctness, scoring, result, dan completion tetap berasal dari konfigurasi assessment yang aktif.

---

## Entitas Inti yang Harus Dipahami Mobile

## Assessment

Assessment adalah container utama yang berisi:

- metadata assessment
- daftar question
- setting navigation
- setting result
- setting scoring
- setting design

## Attempt

Attempt adalah satu sesi pengerjaan student terhadap satu assessment.

Attempt minimal punya state:

- belum mulai
- in progress
- completed

Attempt juga menjadi anchor untuk:

- urutan question aktif
- jawaban student
- time started
- time submitted/completed
- result akhir

## Answer

Answer adalah jawaban student per question pada attempt tertentu.

---

## Flow Student Assessment

## 1. Entry

Student membuka assessment dari lesson/module/path yang relevan.

Assessment bisa berada dalam kondisi:

- belum pernah dikerjakan
- sedang in progress
- sudah pernah completed sebelumnya

Aplikasi mobile harus mengikuti rule backend apakah:

- membuat attempt baru
- resume attempt existing
- menampilkan intro
- menampilkan result terakhir

## 2. Start Attempt

Saat student menekan start:

- system membuat atau melanjutkan attempt in progress
- urutan question aktif untuk attempt itu ditentukan
- randomization yang relevan harus menjadi stabil untuk attempt tersebut

## 3. Resume Attempt

Jika attempt masih in progress:

- student kembali ke question aktif terakhir
- answer yang sudah diisi harus tetap tampil
- urutan option yang di-randomize tidak boleh berubah
- jump path yang sudah terbentuk harus tetap konsisten

## 4. Answering

Saat student menjawab:

- jawaban disimpan ke attempt aktif
- validation question dijalankan
- bila valid, engine menentukan next question berdasarkan jump logic atau urutan normal
- bila invalid, UI menampilkan error yang sesuai

## 5. Back Navigation

Student hanya boleh kembali ke question sebelumnya jika:

- `allow_back_navigation = true`

Jika `allow_back_navigation = false`:

- tombol back antar-question tidak boleh tersedia
- student tidak boleh mundur manual ke question sebelumnya

Catatan:

- question yang ter-skip karena jump dan memang tidak pernah dilalui tidak dianggap bagian dari active path
- student tidak bisa masuk ke question yang sebelumnya tidak pernah menjadi bagian dari path aktif

## 6. Submit

Student bisa submit saat:

- engine menyatakan question path aktif sudah selesai
- semua validation final lolos

Saat submit:

- attempt ditandai completed
- result dihitung
- scoring dihitung
- time tracking difinalkan
- result page ditampilkan

---

## Active Path dan Jump Logic

## Definisi

Active path adalah rangkaian question yang benar-benar dilalui student di attempt tersebut.

Path ini bisa berbeda antar-student atau antar-attempt jika:

- ada jump logic
- ada randomization

## Rule

1. Engine menentukan next question berdasarkan jump logic lebih dulu.
2. Jika tidak ada jump yang berlaku, lanjut ke urutan question normal berikutnya.
3. Question yang ter-skip karena jump:
   - tidak tampil ke student
   - tidak menjadi bagian denominator correctness
   - tidak ikut validation submit
4. Jika student kembali ke question sebelumnya dan mengubah jawaban:
   - path berikutnya boleh berubah
   - answer pada branch yang tidak lagi aktif harus diperlakukan konsisten oleh backend sesuai engine web

---

## Validation Umum

Validation student di mobile harus sama dengan web.

Jenis validation minimal:

- required
- min/max bila relevan
- batas pilihan minimum/maksimum bila type mendukung
- valid numeric input
- valid scale selection
- valid option selection

Jika validation gagal:

- question tidak boleh lanjut
- tampilkan pesan error yang jelas di level question
- jangan submit partial invalid state sebagai completed

---

## Question Type Behaviour

## 1. multiple_choice_buttons

Perilaku:

- single select
- student memilih satu option
- bila `allow_other_option = true`, option Other menggunakan `question_options.is_other_option = true`
- jika student memilih Other:
  - pilihan option tetap disimpan
  - teks custom student disimpan di `assessment_answers.answer_text`

## 2. yes_no_maybe

Perilaku:

- single select
- option Maybe hanya tampil jika `show_maybe_answer = true`
- jika `show_maybe_answer = false`, implementasi final boleh tidak mempersist option Maybe selama engine tetap benar

## 3. multiple_choice_checkboxes

Perilaku:

- multi select
- student bisa memilih lebih dari satu option
- jump per option tidak berlaku
- walaupun struktur data umum mendukung jump, engine untuk type ini harus mengabaikannya

## 4. open_text

Perilaku:

- student mengisi text bebas
- v1 tidak ada auto scoring dari isi text
- nilai score bisa `0` atau `null`
- `scoring_category` hanya placeholder struktur
- type ini tidak masuk denominator correctness

## 5. numeric

Perilaku:

- student memasukkan angka
- validasi numeric berlaku
- type ini tidak masuk denominator correctness kecuali di masa depan ada rule grading khusus
- v1 anggap non-correctness-based

## 6. sliding_scale

Perilaku:

- nilai student adalah angka yang dipilih
- score mapping v1 adalah direct mapping dari angka terpilih
- tidak masuk correctness denominator

## 7. linear_scale

Perilaku:

- ditampilkan sebagai beberapa radio button
- jumlah button mengikuti konfigurasi input
- maksimal 12
- score mapping v1 adalah direct mapping angka terpilih
- tidak masuk correctness denominator

## 8. divided_scale

Perilaku:

- mirip linear scale
- pilihan disusun terbagi dalam beberapa kolom sesuai konfigurasi
- score mapping v1 adalah direct mapping angka terpilih
- tidak masuk correctness denominator

## 9. info_screen

Perilaku:

- bukan question yang dijawab
- tampil sebagai informational step
- tombol Next tetap tampil
- v1 tidak perlu auto-advance
- tidak masuk correctness denominator
- tidak masuk gradable question

## 10. Linear/Scale Labels

Field seperti:

- Left
- Center
- Right label

harus dianggap data aktif dan harus dirender di mobile.

## 11. Image or Video

Field image/video pada question diperlakukan sebagai UI contract.
Jika backend field belum final:

- mobile harus siap membaca field ini
- implementasi boleh bertahap
- tetapi struktur render-nya harus dipersiapkan

---

## Correctness, Points, dan Percentage

## Correct Answers

`Correct Answers` tidak berlaku untuk semua scoreboard.

Untuk v1:

- hanya dihitung dari question yang memang punya konsep benar/salah
- artinya hanya question gradable correctness-based yang masuk

Rumus:

- `Correct Answers = jumlah question gradable yang dijawab benar / total question gradable`

Question berikut tidak masuk denominator correctness:

- open_text
- numeric
- sliding_scale
- linear_scale
- divided_scale
- info_screen

## Percentage

`Percentage` pada v1 adalah percentage correctness hanya dari gradable correctness-based questions.

Jika tidak ada gradable question:

- percentage boleh kosong
- atau fallback aman sesuai contract UI

## Points

`Points` tetap menjadi nilai utama untuk scoreboard yang non-correctness-based.

---

## Scoring

## V1 Rule

1. Scale-based types:
   - score user = direct mapping dari angka yang dipilih
2. open_text:
   - score = `0` atau `null`
3. correctness-based option questions:
   - mengikuti rule benar/salah yang ada di backend
4. `scoring_category` untuk v1:
   - `overall_only`

---

## Result Calculation

## Result Ranges

`Result ranges` boleh kosong.

Jika kosong:

- attempt tetap selesai normal
- result akhir menampilkan raw score atau fallback result sederhana

Jika score tidak cocok ke range mana pun:

- `result_range_id` boleh `null`
- UI result tetap harus tampil
- fallback ke raw score tanpa label range

---

## Results Flow di Mobile

Setelah submit:

1. engine menghitung raw score
2. engine menghitung correctness summary jika relevan
3. engine menentukan result range jika ada
4. engine mengembalikan payload result
5. mobile menampilkan result page

Result page minimal mendukung:

- title/label result
- raw score
- percentage jika ada
- correct answers jika ada
- fallback saat tidak ada range
- CTA keluar / kembali sesuai flow produk

---

## Time Tracking

## Rule Utama

Time taken tetap memprioritaskan:

- `submitted_at`

Jika `submitted_at` invalid, misalnya:

- lebih kecil dari `started_at`

maka fallback ke:

- `completed_at`

## Implikasi Mobile

Mobile tidak boleh membuat time calculation lokal sebagai source of truth akhir.
Mobile boleh menampilkan timer lokal untuk UX, tetapi final value tetap mengikuti backend.

---

## Randomization

## Answers Order

Jika `randomize_answers_order = true`:

- randomization harus stabil per attempt
- sekali attempt dimulai, urutan answer tidak boleh berubah saat refresh/resume/reopen mobile app

Mobile tidak boleh merandom ulang sendiri di client jika backend sudah mengirim urutan final.

---

## Persistence dan Recovery

## In Progress

Selama attempt belum completed:

- answer harus tetap bisa diresume
- active path harus tetap konsisten
- question order harus tetap konsisten
- randomized order harus tetap konsisten

## App Close / Reopen

Jika app ditutup dan dibuka lagi:

- student kembali ke attempt in progress
- state terakhir harus dipulihkan dari backend

---

## Preview Admin

Preview admin harus menjalankan engine yang sama dengan student untuk:

- required
- min/max
- jump
- result calculation

Tetapi preview admin:

- tidak boleh persistence ke attempt student
- tidak menulis progress final student
- hanya simulasi

Mobile tidak perlu mengimplementasikan preview admin.

---

## UI/UX Mobile Principles

## Prinsip Umum

1. Fokus pada satu question per screen
2. CTA utama harus jelas:
   - Next
   - Back bila allowed
   - Submit saat final
3. Error tampil inline di bawah/sekitar input question
4. Progress indicator harus stabil
5. Layout harus aman untuk keyboard mobile
6. State loading, retry, dan offline interruption harus jelas

## Screen Minimum

Mobile assessment minimal punya screen:

- intro/start
- question player
- result
- resume state
- loading/error state

## Question Player Mobile

Setiap screen question idealnya memuat:

- progress indicator
- question title/text
- media bila ada
- answer input sesuai type
- validation message
- navigation CTA

## Info Screen

Untuk `info_screen`:

- tampil seperti step normal
- ada tombol Next
- tidak tampil sebagai jawaban

## Scale UI

Untuk scale types:

- tap target harus besar
- label kiri/tengah/kanan harus tetap terlihat
- untuk divided scale, grouping kolom harus jelas di layar kecil

---

## Offline dan Retry Behaviour

## Prinsip

Mobile boleh memiliki UX retry, tetapi source of truth tetap backend.

Jika save answer gagal:

- student tidak boleh dianggap berhasil lanjut permanen sebelum backend menerima save yang valid
- UI harus menunjukkan retry/error state
- jangan diam-diam menganggap answer persisted bila belum sukses

---

## Rule Konsistensi dengan Web

Mobile harus identik dengan web pada aspek:

- urutan flow
- jump
- validation
- correctness
- scoring
- result
- time tracking
- resume
- denominator correctness
- handling info_screen
- handling non-gradable questions

Jika ada perbedaan antara web dan mobile:

- web engine/backend tetap source of truth
- mobile harus disesuaikan ke backend, bukan membuat rule sendiri

---

## Contract Ringkas V1

## Wajib

- start/resume attempt
- render question sesuai type
- required validation
- next/back sesuai rule
- jump logic
- stable randomized answer order
- submit attempt
- result page
- correctness summary sesuai gradable questions only
- time tracking berdasarkan backend
- info_screen support
- scale-based score direct mapping
- open_text tanpa auto scoring

## Tidak Wajib di V1

- auto advance info_screen
- text auto scoring
- Maybe hidden option wajib dipersist
- correctness untuk non-quiz style inputs
- client-side independent scoring engine yang berbeda dari backend

---

## Definisi Final yang Harus Dipegang

1. `Correct Answers` dan `Percentage` tidak universal untuk semua scoreboard.
2. Keduanya di v1 hanya bermakna untuk question gradable correctness-based.
3. Question non-option/non-quiz style tidak masuk denominator correctness.
4. `allow_back_navigation` mengontrol apakah student boleh mundur.
5. Question yang di-skip jump tidak menjadi bagian path aktif jika tidak pernah dilalui.
6. `randomize_answers_order` harus stabil per attempt.
7. Result range boleh kosong.
8. Jika tidak ada range yang cocok, tampilkan fallback raw score.
9. Preview admin mengikuti engine student tanpa persistence.
10. Mobile UI boleh berbeda dari web, tetapi rule engine harus sama.

---

## Penutup

Dokumen ini menjadi dasar implementasi mobile assessment student.
Jika ada kebutuhan baru yang mengubah behavior engine, perubahan harus dianggap perubahan source of truth, bukan variasi UI biasa.
