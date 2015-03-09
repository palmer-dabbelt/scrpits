umount /dev/mapper/crypt-$1
cryptsetup luksClose crypt-$1
