qemu-kvm \
    -m 1024 \
    -smp 2 \
    -soundhw ac97
    -hda $HOME/.local/share/qemu/afreeca.qcow2 \
    "$@"
