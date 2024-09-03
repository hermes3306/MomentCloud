<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Function to log messages
function custom_error_log($message) {
    error_log(date('[Y-m-d H:i:s] ') . $message);
}

custom_error_log("Script started execution");

// Log all received data
custom_error_log("Raw POST data: " . file_get_contents("php://input"));
custom_error_log("POST: " . print_r($_POST, true));
custom_error_log("FILES: " . print_r($_FILES, true));
custom_error_log("Server variables: " . print_r($_SERVER, true));
custom_error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);
custom_error_log("Content Type: " . $_SERVER['CONTENT_TYPE']);

// Increase upload limits
ini_set('upload_max_filesize', '50M');
ini_set('post_max_size', '50M');
ini_set('memory_limit', '256M');

custom_error_log("Current working directory: " . getcwd());
custom_error_log("Script is running as user: " . exec('whoami'));

$upload_dir = '/home/pi/MomentCloud/upload/';

// Check if directory exists, if not, try to create it
if (!file_exists($upload_dir)) {
    if (!mkdir($upload_dir, 0755, true)) {
        custom_error_log("Failed to create upload directory: " . $upload_dir);
        die("Failed to create upload directory.");
    }
}

// Ensure the upload directory is writable
if (!is_writable($upload_dir)) {
    custom_error_log("Upload directory is not writable: " . $upload_dir);
    die("Upload directory is not writable.");
}

// Check if file was uploaded
if (!isset($_FILES['uploadedFile']) || $_FILES['uploadedFile']['error'] === UPLOAD_ERR_NO_FILE) {
    custom_error_log("No file was uploaded");
    die("No file was uploaded.");
}

$upload_file = $upload_dir . basename($_FILES['uploadedFile']['name']);
custom_error_log("Attempting to upload file: " . basename($_FILES['uploadedFile']['name']));
custom_error_log("Uploaded file size: " . $_FILES['uploadedFile']['size'] . " bytes");
custom_error_log("Free disk space: " . disk_free_space("/") . " bytes");

if (move_uploaded_file($_FILES['uploadedFile']['tmp_name'], $upload_file)) {
    echo "File is valid, and was successfully uploaded.";
    custom_error_log("File successfully uploaded: " . $upload_file);
} else {
    echo "-- [php] upload failed. " . basename($_FILES['uploadedFile']['name']);
    custom_error_log("Upload failed for file: " . basename($_FILES['uploadedFile']['name']));
    custom_error_log("Upload error code: " . $_FILES['uploadedFile']['error']);
    custom_error_log("Upload file permissions: " . substr(sprintf('%o', fileperms($upload_dir)), -4));
    custom_error_log("Current script owner: " . posix_getpwuid(posix_geteuid())['name']);
    
    // Additional error information
    switch($_FILES['uploadedFile']['error']) {
        case UPLOAD_ERR_INI_SIZE:
            custom_error_log("The uploaded file exceeds the upload_max_filesize directive in php.ini");
            break;
        case UPLOAD_ERR_FORM_SIZE:
            custom_error_log("The uploaded file exceeds the MAX_FILE_SIZE directive that was specified in the HTML form");
            break;
        case UPLOAD_ERR_PARTIAL:
            custom_error_log("The uploaded file was only partially uploaded");
            break;
        case UPLOAD_ERR_NO_TMP_DIR:
            custom_error_log("Missing a temporary folder");
            break;
        case UPLOAD_ERR_CANT_WRITE:
            custom_error_log("Failed to write file to disk");
            break;
        case UPLOAD_ERR_EXTENSION:
            custom_error_log("File upload stopped by extension");
            break;
        default:
            custom_error_log("Unknown upload error");
            break;
    }
}

// Log PHP configuration
custom_error_log("upload_max_filesize: " . ini_get('upload_max_filesize'));
custom_error_log("post_max_size: " . ini_get('post_max_size'));
custom_error_log("memory_limit: " . ini_get('memory_limit'));
custom_error_log("max_execution_time: " . ini_get('max_execution_time'));
custom_error_log("max_input_time: " . ini_get('max_input_time'));

?>
