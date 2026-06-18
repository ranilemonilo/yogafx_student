# Mobile Fix Brief — Completion, Home Thumbnail, Certificate Removal, Module Completion Email

## Context

Project ini adalah **YogaFX Student Mobile App**.
Saat ini ada beberapa masalah spesifik yang ingin diperbaiki di mobile berdasarkan perilaku aktual aplikasi.

Fokus task ini **bukan audit semua domain**, tetapi memperbaiki 4 masalah konkret berikut:

1. **Completion logic mobile tidak langsung ter-update**
2. **Thumbnail modules di Home tidak muncul**
3. **Certificate milestone/feature harus dihapus dari mobile**
4. **Module completion dari mobile harus memicu email seperti web**

---

## 1. Problem: Completion Logic Mobile

### Actual behavior

Kronologi saat ini:

* User membuka sebuah **lesson** di dalam **module yang hanya memiliki 1 lesson**
* User menonton video lesson sampai habis
* Completion **tidak langsung** muncul
* Lesson dan module **belum langsung centang/completed**
* Jika user keluar dari app, lalu app dihapus dari recent apps / background, lalu app dibuka ulang, **baru** completion muncul
* Saat completion akhirnya muncul setelah app dibuka ulang, yang berubah adalah:

  * **lesson completion**
  * **module completion**

### Important clarifications

* Gejala terjadi saat user **masih berada di lesson screen**
* Module yang dites benar-benar hanya punya **1 lesson**
* Indikasi kuat: masalah ada pada **completion sync / refresh / invalidation / state update**, bukan hanya tampilan UI icon

### Expected behavior

Begitu lesson selesai sesuai rule backend:

* lesson completion harus langsung ter-update
* module completion juga harus langsung ter-update jika memang itu lesson terakhir/satu-satunya
* user **tidak perlu** menutup app atau menghapus app dari recent apps untuk melihat completion

### Suspected area

Audit dan perbaiki area berikut:

* lesson progress update saat video selesai
* invalidation/refresh provider lesson/module/dashboard
* completion sync setelah video finish
* dependency antara lesson completion dan module completion
* apakah backend sudah menerima progress final tapi UI tidak refresh
* apakah backend sendiri baru finalize completion pada reload tertentu

---

## 2. Problem: Module Thumbnails in Home Not Showing

### Actual behavior

* Semua thumbnail **modules di Home** tidak muncul sama sekali
* Yang terlihat hanya area kosong
* Thumbnail **lesson** tetap muncul
* Jadi masalah terlihat spesifik pada **thumbnail module di Home**, bukan semua image di seluruh app

### Expected behavior

* Thumbnail modules di Home harus tampil normal
* Jika backend mengirim relative URL/path, mobile harus menormalisasi dengan benar
* Jika data tidak ada, tampil fallback yang jelas, bukan kosong diam-diam

### Suspected area

Audit dan perbaiki:

* field thumbnail yang dipakai di Home module cards
* URL resolver/normalizer untuk module thumbnail di dashboard/home
* apakah data Home memakai shape berbeda dari module list/detail
* apakah widget image di Home gagal merender karena null/empty/relative path mismatch

---

## 3. Problem: Remove Certificate Milestone / Certificate Feature from Mobile

### Required change

Yang ingin dihapus dari mobile:

* **section milestone certificate di Home**
* **halaman/fitur Certificates di mobile juga ikut dihapus/disembunyikan**

### Expected behavior

* Certificate milestone tidak lagi tampil di Home mobile
* Navigasi/menu/CTA ke certificate juga tidak lagi muncul di mobile
* Route/screen/profile entry yang terkait certificate di mobile harus dibersihkan atau disembunyikan dengan aman
* Jangan merusak domain lain yang tidak terkait

### Important note

Ini adalah keputusan produk/UI untuk mobile.
Fitur certificate tidak perlu muncul di mobile saat ini.

---

## 4. Problem: Module Completion Email Must Trigger from Mobile

### Actual behavior

* Di web, email `module_completion` sudah terbukti terkirim
* Di mobile, completion module tidak langsung ter-update
* Bahkan setelah completion akhirnya muncul setelah reopen app, email tetap **tidak terkirim**

### Expected behavior

Begitu module completion terjadi dari flow mobile:

* backend harus memicu flow/event/email yang sama seperti web
* email `module_completion` harus terkirim tanpa perlu restart app
* mobile tidak boleh menjadi jalur completion yang “berbeda” dari web

### Suspected area

Audit dan perbaiki:

* apakah mobile hanya update lesson progress tetapi tidak masuk ke jalur backend yang men-trigger module completion event
* apakah completion module dari mobile dihitung hanya secara read model, tanpa event dispatch
* apakah endpoint mobile berbeda behavior dengan web
* apakah event/email trigger hanya terpasang di flow web

---

## Scope

Task ini hanya fokus pada 4 area berikut:

1. completion logic mobile
2. home module thumbnails
3. certificate milestone/feature removal from mobile
4. module completion email trigger from mobile

Jangan melebar ke domain lain kecuali memang dibutuhkan langsung untuk menyelesaikan 4 masalah ini.

---

## Required Work Style

Kerjakan secara bertahap:

1. **Audit dulu**

   * temukan root cause aktual per masalah
   * bedakan mana masalah UI, mana state sync, mana backend flow

2. **Ringkas temuan**

   * apa yang salah
   * file/domain yang terlibat
   * apakah masalah ada di mobile only, backend only, atau integration gap

3. **Buat patch minimal dan aman**

   * jangan refactor besar yang tidak perlu

4. **Implement**

   * lakukan perubahan yang diperlukan

5. **Verify**

   * buktikan tiap masalah benar-benar selesai

---

## Expected Output from Codex

Codex harus menghasilkan:

### 1. Audit Findings

Per poin:

* completion logic
* home thumbnail
* certificate removal
* module completion email

### 2. Root Cause

Akar masalah masing-masing poin

### 3. Minimal Patch Plan

Per file/domain yang relevan

### 4. Implementation

Perubahan aktual

### 5. Verification

Checklist hasil akhir:

* lesson completion langsung update
* module completion langsung update
* tidak perlu force close/reopen app
* thumbnail modules di Home muncul
* certificate milestone tidak tampil
* certificate feature/route/menu di mobile tidak tampil
* module completion dari mobile memicu email seperti web

---

## Definition of Done

Task ini dianggap selesai jika:

* completion lesson/module dari mobile **langsung** ter-update tanpa perlu menutup app
* module thumbnail di Home tampil normal
* certificate milestone dan certificate feature sudah hilang dari mobile UI/navigation
* module completion dari mobile memicu email `module_completion` yang sama seperti web
* perubahan aman dan tidak melebar tidak perlu
