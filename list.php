<?php
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', 'list_error.log');
error_reporting(E_ALL);

// Define the base directory
$moment_home = '/home/pi/MomentCloud';
$upload_dir = $moment_home . '/upload/';

// Sanitize input
function sanitize_dir($dir) {
    return preg_replace('/[^a-zA-Z0-9\-_\/]/', '', $dir);
}

function sanitize_ext($ext) {
    return preg_replace('/[^a-zA-Z0-9\*]/', '', $ext);
}

// Get and sanitize input
$dir = isset($_GET['dir']) ? sanitize_dir($_GET['dir']) : 'upload';
$ext = isset($_GET['ext']) ? sanitize_ext($_GET['ext']) : '*';
$page = isset($_GET['page']) ? max(1, intval($_GET['page'])) : 1;
$limit = isset($_GET['limit']) ? max(1, intval($_GET['limit'])) : 10000;

// Construct the full path
$path = realpath($moment_home . '/' . $dir);

// Ensure the path is within the allowed directory
if ($path === false || strpos($path, realpath($moment_home)) !== 0) {
    die("Access denied");
}

// Use a whitelist of allowed extensions
$allowed_extensions = ['json', 'mp3', 'jpg', 'jpeg', 'png', 'gif', 'mp4', 'csv', 'txt', '*'];
if (!in_array($ext, $allowed_extensions)) {
    die("Invalid file extension");
}

// Get the list of files
$files = glob($path . "/*" . ($ext !== '*' ? ".$ext" : ''), GLOB_BRACE);

// Sort files by modification time (most recent first)
usort($files, function($a, $b) {
    return filemtime($b) - filemtime($a);
});

// Calculate pagination
$total_files = count($files);
$total_pages = ceil($total_files / $limit);
$offset = ($page - 1) * $limit;
$files = array_slice($files, $offset, $limit);

// Generate the list of files
$thelist = "";
foreach($files as $f) {
    if (is_file($f)) {
        $fname = basename($f);
        $thelist .= htmlspecialchars($fname, ENT_QUOTES, 'UTF-8') . '<br>';
    }
}

// Output the list
if (empty($thelist)) {
    echo "No files found.";
} else {
    echo $thelist;
}

// Log the access
error_log("List accessed for directory: $dir, extension: $ext, page: $page, limit: $limit");
?>
