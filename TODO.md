# TODO: Integrasi Geocoding untuk Menampilkan Alamat di Google Maps

## Langkah-langkah:
1. Tambahkan dependensi geocoding ke pubspec.yaml.
2. Jalankan flutter pub get untuk menginstall dependensi baru.
3. Modifikasi home_screen.dart untuk mengimport geocoding dan menambahkan logika untuk mendapatkan alamat dari koordinat.
4. Tambahkan variabel untuk menyimpan alamat saat ini.
5. Update fungsi getCurrentLocation dan onLocationChanged untuk mengambil alamat menggunakan placemarkFromCoordinates.
6. Tampilkan alamat di UI, misalnya di bottom sheet di bawah kartu KEY.
7. Test aplikasi untuk memastikan lokasi dan alamat ditampilkan dengan benar.
8. Pastikan izin lokasi diberikan dan layanan lokasi diaktifkan di Windows.

## Status:
- [x] 1. Tambahkan dependensi geocoding
- [x] 2. Jalankan flutter pub get
- [x] 3. Modifikasi home_screen.dart - import geocoding
- [x] 4. Tambahkan variabel alamat
- [x] 5. Update fungsi lokasi untuk geocoding
- [x] 6. Tampilkan alamat di UI
- [x] 7. Test aplikasi
- [x] 8. Verifikasi izin lokasi
