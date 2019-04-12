<?php
$mysqli = new mysqli('192.168.4.11','root','','mysql');
if (mysqli_connect_errno()){
	die('Unable to connect!'). mysqli_connect_error();
}
$sql = "select * from user";
$result = $mysqli->query($sql);
while($row = $result->fetch_array()){
	printf("Host:%s",$row[0]);
	printf("</br>");
	printf("Name:%s",$row[1]);
	printf("</br>");
}
?>
