#!/bin/bash
echo "start"

DEFAULT_LABEL="Drive"
echo "defset"
while true; do
  # List all mounted USB drives
  USB_DRIVES=$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -e 'sd[b-z]\s*disk\s*/media/' | awk '{print $1}')

  if [ -n "$USB_DRIVES" ]; then
    echo "USB drives detected: $USB_DRIVES"

    # Iterate over all detected USB drives
    for drive in $USB_DRIVES; do
      echo "Processing drive: $drive"

      echo "Wiping drive $drive..."
      sudo sgdisk --zap-all "/dev/$drive"

      echo "Checking drive $drive for bad blocks..."
      badblocks -nsv "/dev/$drive" 2>&1 | tee "/tmp/badblocks.$drive.log"

      if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "Formatting drive $drive with label: $DEFAULT_LABEL..."
        sudo mkfs.ntfs -f -v -L "$DEFAULT_LABEL" "/dev/$drive"
      else
        echo -e "\e[31mBad blocks found on drive $drive. Drive not formatted.\e[0m"
      fi
    done

    # Notify job completion with green background
    echo -e "\e[42mJob Completed\e[0m"
  else
    echo "No USB drives found. Waiting..."
    sleep 2
  fi
done
