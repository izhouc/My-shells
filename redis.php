<?php
$redis = new redis();
$redis->connect("192.168.4.50",6350);
$redis->auth("123456");
$redis->set("school","tarena");
echo $redis->get("school");
?>
