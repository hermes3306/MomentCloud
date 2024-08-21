<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Log all received data
error_log("Raw POST data: " . file_get_contents("php://input"));
error_log("POST: " . print_r($_POST, true));
error_log("FILES: " . print_r($_FILES, true));
error_log("Server variables: " . print_r($_SERVER, true));

error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Content Type: " . $_SERVER['CONTENT_TYPE']);
error_log("POST data: " . print_r($_POST, true));
error_log("FILES data: " . print_r($_FILES, true));
error_log("Raw input: " . file_get_contents('php://input'));

ini_set('upload_max_filesize', '10M');
ini_set('post_max_size', '10M');

ini_set('display_errors', 1);
ini_set('log_errors', 1);
error_reporting(E_ALL);

error_log("Script started execution");
error_log("Current working directory: " . getcwd());
error_log("Script is running as user: " . exec('whoami'));

$upload_dir = '/home/pi/MomentCloud/upload/';

// Check if directory exists, if not, try to create it
if (!file_exists($upload_dir)) {
    if (!mkdir($upload_dir, 0755, true)) {
        error_log("Failed to create upload directory: " . $upload_dir);
        die("Failed to create upload directory.");
    }
}

// Ensure the upload directory is writable
if (!is_writable($upload_dir)) {
    error_log("Upload directory is not writable: " . $upload_dir);
    die("Upload directory is not writable.");
}

$upload_file = $upload_dir . basename($_FILES['file']['name']);

error_log("Attempting to upload file: " . basename($_FILES['file']['name']));
error_log("Uploaded file size: " . $_FILES['file']['size'] . " bytes");
error_log("Free disk space: " . disk_free_space("/") . " bytes");

if (move_uploaded_file($_FILES['file']['tmp_name'], $upload_file)) {
    echo "File is valid, and was successfully uploaded.";
    error_log("File successfully uploaded: " . $upload_file);
} else {
    echo "-- [php] upload failed. " . basename($_FILES['file']['name']);
    error_log("Upload failed for file: " . basename($_FILES['file']['name']));
    error_log("Upload error code: " . $_FILES['file']['error']);
    error_log("Upload file permissions: " . substr(sprintf('%o', fileperms($upload_dir)), -4));
    error_log("Current script owner: " . posix_getpwuid(posix_geteuid())['name']);
    
    // Additional error information
    switch($_FILES['file']['error']) {
        case UPLOAD_ERR_INI_SIZE:
            error_log("The uploaded file exceeds the upload_max_filesize directive in php.ini");
            break;
        case UPLOAD_ERR_FORM_SIZE:
            error_log("The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form");
            break;
        case UPLOAD_ERR_PARTIAL:
            error_log("The uploaded file was only partially uploaded");
            break;
        case UPLOAD_ERR_NO_FILE:
            error_log("No file was uploaded");
            break;
        case UPLOAD_ERR_NO_TMP_DIR:
            error_log("Missing a temporary folder");
            break;
        case UPLOAD_ERR_CANT_WRITE:
            error_log("Failed to write file to disk");
            break;
        case UPLOAD_ERR_EXTENSION:
            error_log("File upload stopped by extension");
            break;
        default:
            error_log("Unknown upload error");
            break;
    }
}

// Log PHP configuration
error_log("upload_max_filesize: " . ini_get('upload_max_filesize'));
error_log("post_max_size: " . ini_get('post_max_size'));
error_log("memory_limit: " . ini_get('memory_limit'));
?>
