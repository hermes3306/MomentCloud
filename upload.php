<?php
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', '/home/pi/MomentCloud/upload_error.log');
error_reporting(E_ALL);

$upload_dir = '/home/pi/MomentCloud/upload/';
$upload_file = $upload_dir . basename($_FILES['file']['name']);

error_log("Attempting to upload file to: " . $upload_file);

if (move_uploaded_file($_FILES['file']['tmp_name'], $upload_file)) {
    echo "File is valid, and was successfully uploaded.";
} else {
    echo "Upload failed.";
    error_log("Upload failed. Error code: " . $_FILES['file']['error']);
    error_log("Upload file permissions: " . substr(sprintf('%o', fileperms($upload_dir)), -4));
    error_log("Current script owner: " . posix_getpwuid(posix_geteuid())['name']);
}
?>
