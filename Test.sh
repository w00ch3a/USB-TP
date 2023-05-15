#!/bin/bash

DEFAULT_LABEL="Christmas"

while true; do

  # List all mounted USB drives

  USB_DRIVES=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -e 'sd[b-z]\s*disk\s*/media/' | awk '{print $1}')

  if [ -n "$USB_DRIVES" ]; then

    # Iterate over all detected USB drives

    for drive in $USB_DRIVES; do

      echo "Wiping drive $drive..."

      sudo sgdisk --zap-all "/dev/$drive"

      echo "Checking drive $drive for bad blocks..."

      badblocks -nsv "/dev/$drive" 2>&1 | tee "/tmp/badblocks.$drive.log"

      if [ ${PIPESTATUS[0]} -eq 0 ]; then

        # Prompt for drive name with a timeout of 20 seconds

        read -r -t 20 -p "Enter drive name (default: $DEFAULT_LABEL): " drive_name || true

        # Use default drive name if no input is provided

        drive_name=${drive_name:-$DEFAULT_LABEL}

        echo "Formatting drive $drive with label: $drive_name..."

        sudo mkfs.ntfs -f -v -L "$drive_name" "/dev/$drive"

      else

        echo -e "\e[31mBad blocks found on drive $drive. Drive not formatted.\e[0m"

      fi

    done

    # Notify job completion with green background

    echo -e "\e[42mJob Completed\e[0m"

  else

    sleep 2

  fi

done
