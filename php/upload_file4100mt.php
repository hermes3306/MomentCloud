<?php
$allowedExts = array("ser2", "xls", "csv", "mnt",  "gif", "jpeg", "jpg", "png");

if (isset($_FILES)) {
    $file = $_FILES["file"];
    $error = $file["error"];
    $name = $file["name"];
    $type = $file["type"];
    $size = $file["size"];
    $tmp_name = $file["tmp_name"];

	$res = "name: " . $name . "<br>";
	$res = $res . "type: " . $type . "<br>";
	$res = $res . "size: " . $size . "<br>";

   
    if ( $error > 0 ) {
        echo "Error: " . $error . "<br>";
    }
    else {
        $temp = explode(".", $name);
        $extension = end($temp);
       
        if ( ($size/1024/1024) < 20. && in_array($extension, $allowedExts) ) {
            //echo "Upload: " . $name . "<br>";
            //echo "Type: " . $type . "<br>";
            //echo "Size: " . ($size / 1024 / 1024) . " Mb<br>";
            //echo "Stored in: " . $tmp_name;
            if (file_exists(getcwd() . "/upload100/" . $name)) {
				echo $res . "<br>";
                echo $name . " already exists. ";
            }
            else {
                move_uploaded_file($tmp_name, getcwd() ."/upload100/" . $name);
                echo "Stored in: " . "upload100/" . $name;
            }
        }
        else {
			echo $res . "<br>";
            echo ($size/1024/1024) . " Mbyte is bigger than 20 Mb ";
            echo $extension . "format file is not allowed to upload ! ";
        }
    }
}
else {
    echo "File is not selected";
}
?>
