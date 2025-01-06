#!/bin/bash

/usr/bin/usbdevice stop
echo usb_mtp_en > /tmp/.usb_config
/usr/bin/usbdevice start