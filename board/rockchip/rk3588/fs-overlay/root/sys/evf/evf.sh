#!/bin/bash

# Default action
ACTION=${1:-Unknown}

# Hardware Paths
DSI_PATH="/sys/class/drm/card0-DSI-2/status"
GPIO_PATH="/dev/jp_hgd_gpio_ctl_enable_evf"

##############################################################################################
######################################## Par I: Basic ########################################
##############################################################################################

# Brief: Set DSI status (on/off)
# Args: $1 - "on" or "off"
# Return: 0 success; 1 file not found; 2 write failed
Func_SetDsiStatus()
{
    local status="$1"

    # Check if path exists
    if [ ! -f "${DSI_PATH}" ]; then
        echo "Error: DSI path ${DSI_PATH} not found"
        return 1
    fi

    echo "Setting DSI status to: ${status}"
    if ! echo "${status}" > "${DSI_PATH}"; then
        echo "Error: Failed to write to DSI path"
        return 2
    fi

    return 0
}

# Brief: Set GPIO Enable (0/1)
# Args: $1 - "0" or "1"
# Return: 0 success; 1 file not found; 2 write failed
Func_SetGpioEnable()
{
    local value="$1"

    # Check if device exists
    if [ ! -e "${GPIO_PATH}" ]; then
        echo "Error: GPIO device ${GPIO_PATH} not found"
        return 1
    fi

    echo "Setting GPIO enable to: ${value}"
    if ! echo "${value}" > "${GPIO_PATH}"; then
        echo "Error: Failed to write to GPIO device"
        return 2
    fi

    return 0
}

##############################################################################################
######################################## Par II: APIs ########################################
##############################################################################################

# Brief: Turn EVF On
# Sequence: GPIO Enable (1) -> DSI On
# Return: 0 success; >0 failed step
API_TurnOn()
{
    local ret=0

    echo "Starting EVF Power On sequence..."

    # Step 1: Enable GPIO
    # Original logic: echo 1 > /dev/jp_hgd_gpio_ctl_enable_evf
    echo "Step 1: Enabling GPIO..."
    Func_SetGpioEnable "1"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: GPIO enable failed with error $ret"
        return 1
    fi

    sleep 1

    # Step 2: Turn on DSI
    # Original logic: echo on > /sys/class/drm/card0-DSI-2/status
    echo "Step 2: Turning on DSI..."
    Func_SetDsiStatus "on"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: DSI enable failed with error $ret"
        return 2
    fi

    echo "EVF Turned On successfully"
    return 0
}

# Brief: Turn EVF Off
# Sequence: DSI Off -> GPIO Disable (0)
# Return: 0 success; >0 failed step
API_TurnOff()
{
    local ret=0

    echo "Starting EVF Power Off sequence..."

    # Step 1: Turn off DSI
    # Original logic: echo off > /sys/class/drm/card0-DSI-2/status
    echo "Step 1: Turning off DSI..."
    Func_SetDsiStatus "off"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 1: DSI disable failed with error $ret"
        return 1
    fi

    # Step 2: Disable GPIO
    # Original logic: echo 0 > /dev/jp_hgd_gpio_ctl_enable_evf
    echo "Step 2: Disabling GPIO..."
    Func_SetGpioEnable "0"
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed at Step 2: GPIO disable failed with error $ret"
        return 2
    fi

    echo "EVF Turned Off successfully"
    return 0
}

###############################################################################################
######################################## Par III: main ########################################
###############################################################################################

main()
{
    local ret=0

    # Print usage if help is requested
    if [ "$ACTION" = "-h" ] || [ "$ACTION" = "--help" ]; then
        echo "Usage: $0 [ACTION]"
        echo "Actions:"
        echo "  on   - Turn EVF On (GPIO -> DSI)"
        echo "  off  - Turn EVF Off (DSI -> GPIO)"
        return 0
    fi

    # Execute requested action
    case "$ACTION" in
        "on"|"On"|"ON")
            API_TurnOn
            ret=$?
            ;;

        "off"|"Off"|"OFF")
            API_TurnOff
            ret=$?
            ;;
            
        *)
            echo "Error: Unknown action '$ACTION'"
            echo "Use '$0 --help' for usage information"
            return 1
            ;;
    esac

    return $ret
}

main