#!/bin/bash
	ping -c 3 -i 0.1 -W 1  176.4.11.37
expect << EOF
	ssh -o StrictHostKeyChecking=no server0
	spawn ssh  176.4.11.$i
	expect "password:" { send "Taren1\r"}
	expect "#" { send "poweroff\r"}
	expect "#" { send "exit\r"}
EOF

poweroff
