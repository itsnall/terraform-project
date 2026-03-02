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
    echo "<h1 style='color: red;'>Database Connection FAILED ❌</h1>";
    echo "<p>Error Message: <b>" . $conn->connect_error . "</b></p>";
    echo "<hr style='width: 50%;'>";
    echo "<h3>Possible Causes:</h3>";
    echo "<ul style='text-align: left; display: inline-block;'>";
    echo "<li>Username/Password in the <code>user-data.sh</code> file do not match the RDS module settings.</li>";
    echo "<li>RDS Database Security Group does not allow inbound Port 3306 access from EC2.</li>";
    echo "</ul>";
} else {
    echo "<h1 style='color: green;'>Yay! Success! ✅</h1>";
    echo "<h2>This website is now using a separate <code style='background: #eee; padding: 5px;'>index.php</code> file!</h2>";
    echo "<p>Connection to RDS MySQL is running smoothly without issues.</p>";
}

echo "</div>";
?>