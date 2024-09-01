<?php
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'delete_error.log');
error_reporting(E_ALL);

// Define the base directory
$moment_home = '/home/pi/MomentCloud';
$upload_dir = $moment_home . '/upload/';

// Function to sanitize filename
function sanitize_filename($filename) {
    // Remove any character that is not alphanumeric, underscore, dash, or dot
    return preg_replace('/[^a-zA-Z0-9_\-\.]/', '', $filename);
}

// Check if filename is provided
if (!isset($_GET['filename']) || empty($_GET['filename'])) {
    echo "Error: No filename provided";
    exit;
}

// Sanitize the filename
$filename = sanitize_filename($_GET['filename']);

// Construct the full path
$filepath = $upload_dir . $filename;

// Check if the file exists
if (!file_exists($filepath)) {
    echo "Error: File does not exist";
    exit;
}

// Attempt to delete the file
if (unlink($filepath)) {
    echo "success";
} else {
    echo "Error: Unable to delete file";
}

// Log the deletion attempt
error_log("Delete attempt for file: $filename - " . (file_exists($filepath) ? "Failed" : "Successful"));
?>
