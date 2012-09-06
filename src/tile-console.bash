tmp=`mktemp -d`
device="/dev/ttyUSB0"

cat >$tmp/tile-console.kerm <<EOF
# This should only be used by "tile-console",
# which will pass in the console serial port as an argument.
set line \%1
if fail {
  echo "Failed to open and lock the serial port device '\%1'."
  echo ""
  echo "If nobody else is using that serial device, you might need to run"
  echo "this script as root; add yourself to the appropriate Unix group"
  echo "(e.g. the 'uucp' group); or change the permissions on the device,"
  echo "either via udev, or manually by adding 'chmod' commands to your"
  echo "/etc/rc.local."
  echo ""
  echo "Note that the tile drivers automatically do 'chmod 666' on"
  echo "any serial device mentioned in an '/etc/tile*.conf' file."
  echo ""
  echo "Please contact your system administrator for more help if necessary."
  exit 1
}
set speed 115200
eightbit
set flow-control none
set carrier-watch off
connect
EOF

ckermit.ini + $tmp/tile-console.kerm $device

rm -rf $tmp
