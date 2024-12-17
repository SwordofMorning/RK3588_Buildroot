#!/bin/sh

module_name="bcmdhd"

while true
do
	if lsmod | grep -q "bcmdhd"; then
		if ifconfig wlan0 > /dev/null 2>&1; then
			wpa_supplicant=$(ps -aux | grep "wpa_supplicant"  |  grep -v grep | awk '{print $11}')
			if [[ -n $wpa_supplicant ]]; then
				wpa_state=$(wpa_cli -i wlan0 status | grep "wpa_state=")
				if [ "$wpa_state" = "wpa_state=COMPLETED" ]; then
					ipok=$(ifconfig wlan0 | grep 'inet ' | awk '{print $2}')
					if [ -z $ipok ];then
						udhcpc -i wlan0
						echo "ip:---.---.---.---"
						sleep 5
					fi
				else
				   echo "wpa_state=DISCONNECTED"
				   pkill wpa_supplicant
				   sleep 1
				   wpa_supplicant -Dnl80211 -c /etc/wpa_supplicant.conf -i wlan0 &
				   sleep 5
				fi
			else
				echo "wpa_supplicant is not running"
				sleep 3
				wpa_supplicant -Dnl80211 -c /etc/wpa_supplicant.conf -i wlan0 &
				sleep 10
			fi
		else
			echo "wlan0 does not exist."
		fi
	else
		insmod /vendor/lib/modules/bcmdhd.ko
	fi

	sleep 1
done