#!/bin/sh
# Test updating msdos table doesn't replace MBR boot code

# Copyright (C) 2026 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/init.sh"; path_prepend_ ../parted
require_hexdump_

dev=loop-file

# create device
truncate --size 10MiB "$dev" || fail=1

write_fixed_msdos_disk_id ()
{
  case $# in
    1) local dev=$1;;
    *) echo "usage: write_fixed_msdos_disk_id DEVICE" 1>&2; return 1;;
  esac
  echo -e '\x12\x34\x56\x78' | dd bs=1 seek=440 count=4 of=$dev status=none conv=notrunc
}

write_byte_pattern ()
{
  case $# in
    2) local len=$1; local dev=$2;;
    *) echo "usage: write_byte_pattern LENGTH DEVICE" 1>&2; return 1;;
  esac
  case $len in
    *[^0-9]*) echo "write_byte_pattern: invalid length: $len" 1>&2; return 1;;
  esac
  perl -e '
    $len='"$len"';
    $str = "\xde\xad\xbe\xef" x int(($len + 4) / 4);
    printf("%.*s", $len, $str);' | \
  dd bs=$len count=1 of=$dev status=none conv=notrunc
}

echo '#1: Fill first sector with byte pattern and create new msdos table.'
echo '#1: Expect zero filled boot code and new msdos table.'
cat << 'EOF' > exp
00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001b0  00 00 00 00 00 00 00 00  12 34 56 78 00 00 00 00  |.........4Vx....|
000001c0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001f0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 55 aa  |..............U.|
00000200
EOF
write_byte_pattern 512 $dev || fail=1
parted --script $dev mklabel msdos || fail=1
write_fixed_msdos_disk_id $dev || fail=1
dd if=$dev bs=512 count=1 status=none | hexdump -C > out 2>&1
compare exp out || fail=1

echo '#2: Update msdos table.'
echo '#2: Expect zeroed boot code maintained.'
dd if=/dev/zero bs=440 count=1 of=$dev status=none conv=notrunc || fail=1
dd if=$dev bs=440 count=1 status=none | hexdump -C > exp 2>&1
parted --script $dev mkpart primary ext2 1M 5M || fail=1
dd if=$dev bs=440 count=1 status=none | hexdump -C > out 2>&1
compare exp out || fail=1

echo '#3: Fill boot code with byte pattern and update msdos table.'
echo '#3: Expect boot code maintained.'
write_byte_pattern 440 $dev || fail=1
dd if=$dev bs=440 count=1 status=none | hexdump -C > exp 2>&1
parted --script $dev mkpart primary ext2 5M 10M || fail=1
dd if=$dev bs=440 count=1 status=none | hexdump -C > out 2>&1
compare exp out || fail=1

Exit $fail
