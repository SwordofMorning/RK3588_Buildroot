#!/bin/bash

# 定义输出文件路径
OUTPUT_FILE="/root/sys/version/ver.ini"

# 获取kernel信息
KERNEL_INFO=$(uname -a)
# 提取完整版本号，然后只保留最后的commit hash
KERNEL_VERSION=$(echo "$KERNEL_INFO" | awk '{print $3}' | grep -o '[a-f0-9]\{12\}$')
KERNEL_BUILD_TIME=$(echo "$KERNEL_INFO" | awk '{print $7" "$8" "$9" "$10" "$11}')

# 获取fs信息
FS_INFO=$(cat /etc/os-release)
# 提取版本号，去掉开头的-g
FS_VERSION=$(echo "$FS_INFO" | grep "VERSION=" | head -n 1 | cut -d'=' -f2 | tr -d '"' | sed 's/^-g//')
FS_BUILD_INFO=$(echo "$FS_INFO" | grep "BUILD_INFO=" | cut -d'"' -f2)
FS_BUILD_HOST=$(echo "$FS_BUILD_INFO" | awk '{print $1}')
FS_BUILD_TIME=$(echo "$FS_BUILD_INFO" | awk '{print $2" "$3" "$4" "$5" "$6}')

# 获取CPU序列号
CPU_SERIAL=$(cat /proc/cpuinfo | grep "Serial" | awk '{print $3}')

# 创建ini文件
cat > "$OUTPUT_FILE" << EOL
; System Version Information
; Generated on $(date)
; This file contains kernel and filesystem information

[kernel]
; Kernel version information
version=${KERNEL_VERSION}
; Kernel build time
build_time=${KERNEL_BUILD_TIME}

[filesystem]
; Filesystem version information
version=${FS_VERSION}
; Filesystem build time
build_time=${FS_BUILD_TIME}
; Build host information
build_host=${FS_BUILD_HOST}

[hardware]
; CPU serial number
cpu_serial=${CPU_SERIAL}
EOL

# 检查文件是否创建成功
if [ -f "$OUTPUT_FILE" ]; then
    echo "Version information has been written to $OUTPUT_FILE"
else
    echo "Error: Failed to create $OUTPUT_FILE"
    exit 1
fi