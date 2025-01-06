#!/bin/bash

echo usb_adb_en > /tmp/.usb_config
echo usb_rndis_en > /tmp/.usb_config
/usr/bin/usbdevice restart
ifconfig usb0 up
ifconfig usb0 169.254.43.1 netmask 255.255.0.0 up