<?php 
include('common.php'); 

$dir = isset($_GET['dir']) ? sanitize_dir($_GET['dir']) : 'upload';
$ext = isset($_GET['ext']) ? sanitize_ext($_GET['ext']) : '*';

$path = $moment_home . '/' . $dir;

// Ensure the path is within the allowed directory
if (strpos(realpath($path), realpath($moment_home)) !== 0) {
    die("Access denied");
}

$files = glob($path . "/*." . $ext, GLOB_BRACE);
$thelist = "";

foreach($files as $f) {
    if (is_file($f)) {
        $fname = basename($f);
        $thelist .= htmlspecialchars($fname, ENT_QUOTES, 'UTF-8') . '<br>';
    }
}

echo $thelist;
?>
