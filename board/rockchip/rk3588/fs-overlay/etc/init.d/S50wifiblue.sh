#!/bin/sh
case "$1" in
        start|"")
		mkdir -p /data/cfg
		cp /etc/wpa_supplicant.conf /data/cfg
                insmod /usr/local/modules/8723du.ko
                insmod /usr/local/modules/rtk_btusb.ko
		export $(dbus-launch)
		/usr/libexec/bluetooth/obexd -r /opt/ -a -d &
		hciconfig hci0 up
		hciconfig hci0 piscan
		echo nameserver 114.114.114.114 > /etc/resolv.conf
                ;;
        stop|status)
                rmmod /usr/local/modules/8723du.ko
                rmmod /usr/local/modules/rtk_btusb.ko
                ;;
        *)
                echo "Usage: start" >&2
                exit 3
                ;;
esac
