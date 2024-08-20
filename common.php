<?php
    $moment_home = "/home/pi/MomentCloud";
    $dbfile      = "/home/pi/MomentCloud/Moment.db";
    $moment_url  = "http://58.233.69.198/moment";


// Function to sanitize directory input
function sanitize_dir($dir) {
    $dir = trim($dir);
    $dir = str_replace('..', '', $dir); // Remove potential directory traversal
    $dir = preg_replace('/[^a-zA-Z0-9\-_\/]/', '', $dir); // Allow only alphanumeric, dash, underscore, and forward slash
    return $dir;
}

// Function to sanitize file extension input
function sanitize_ext($ext) {
    $ext = trim($ext);
    return preg_replace('/[^a-zA-Z0-9]/', '', $ext); // Allow only alphanumeric characters
}
>
