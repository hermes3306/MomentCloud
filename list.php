<?php
	$dir = $_GET['dir'];
	$ext = $_GET['ext'];

        if( is_null($ext)) $ext = "*";
        if( is_null($dir)) $dir = "upload";

        $path = '/home/pi/MomentCloud/upload';
        $files = glob($path . "/*." . $ext, GLOB_BRACE);
        $listfiles=array();
        $thelist ="";
        foreach($files as $f){
          if ($f != "." && $f != "..") {
            // $thelist = $thelist.$f.'<br>';
                        $fname = basename($f);
            $thelist = $thelist. $fname. '<br>';
          }
        }
        echo $thelist;
?>
