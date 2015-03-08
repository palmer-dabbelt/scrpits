ls /etc/disk-keys/ | while read f
                    do
                        cryptsetup luksOpen \
                                   -d /etc/disk-keys/$f \
                                   --allow-discards \
                                   $1 crypt-$f || continue
                        mount /dev/mapper/crypt-$f
                    done
