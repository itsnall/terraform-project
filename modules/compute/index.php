<?php
// Memanggil data koneksi dari file config
include 'config.php';

// Mencegah PHP 8 memunculkan layar 500 error saat koneksi gagal
mysqli_report(MYSQLI_REPORT_OFF);

// Menghubungkan ke database (@ untuk menyembunyikan warning bawaan)
$conn = @new mysqli($host, $user, $pass, $db);

echo "<div style='font-family: sans-serif; text-align: center; margin-top: 50px;'>";

// Jika koneksi gagal, tampilkan pesan error yang jelas
if ($conn->connect_error) {
    echo "<h1 style='color: red;'>Koneksi Database GAGAL ❌</h1>";
    echo "<p>Pesan Error: <b>" . $conn->connect_error . "</b></p>";
    echo "<hr style='width: 50%;'>";
    echo "<h3>Kemungkinan Penyebab:</h3>";
    echo "<ul style='text-align: left; display: inline-block;'>";
    echo "<li>Username/Password di file <code>user-data.sh</code> tidak sama dengan setelan di modul RDS.</li>";
    echo "<li>Security Group Database RDS belum mengizinkan akses masuk Port 3306 dari EC2.</li>";
    echo "</ul>";
} else {
    echo "<h1 style='color: green;'>Yeay! Berhasil! ✅</h1>";
    echo "<h2>Website ini sekarang menggunakan file <code style='background: #eee; padding: 5px;'>index.php</code> yang terpisah!</h2>";
    echo "<p>Koneksi ke RDS MySQL berjalan lancar tanpa kendala.</p>";
}

echo "</div>";
?>