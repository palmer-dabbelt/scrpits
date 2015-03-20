ls /etc/disk-keys/ | while read f
                    do
                        cryptsetup luksOpen \
                                   -d /etc/disk-keys/$f \
                                   --allow-discards \
                                   $1 crypt-$f || continue
                        mount /dev/mapper/crypt-$f && exit 0
                        cryptsetup luksClose crypt-$f
                        exit 1
                    done
