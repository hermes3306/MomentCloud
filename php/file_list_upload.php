<?php
 if ($handle = opendir('./upload')) {
   while (false !== ($file = readdir($handle))) {
          if ($file != "." && $file != "..") {
            //$thelist = $thelist.$file.'<br>';
            $thelist = $thelist.$file."\r\n";
          }
       }
  closedir($handle);
  }
 echo $thelist;
?>
