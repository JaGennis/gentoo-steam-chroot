#!/bin/sh

xhost +local:

# path to game partition
game_part="PARTITION_PATH"

# steam chroot bits
chroot_bits="64"

# steam chroot directory
chroot_dir="/usr/local/steam64"

# check if chroot bits is valid
if [ "${chroot_bits}" = "32" ] ; then
  chroot_arch="linux32"
elif [ "${chroot_bits}" = "64" ] ; then
  chroot_arch="linux64"
else
  printf "Invalid chroot bits value '%s'. Permitted values are '32' and '64'.\n" "${chroot_bits}"
  exit 1
fi

# check if the chroot directory exists
if [ ! -d "${chroot_dir}" ] ; then
  printf "The chroot directory '%s' does not exist!\n" "${chroot_dir}"
  exit 1
fi

# mount the chroot directories
mount -v -t proc /proc "${chroot_dir}/proc"
mount -vR /sys "${chroot_dir}/sys"
mount -vR /dev "${chroot_dir}/dev"
mount -vR /run "${chroot_dir}/run"
mount -vR /var/db/repos/gentoo "${chroot_dir}/var/db/repos/gentoo"

mount --bind -v /var/lib/dbus "${chroot_dir}/var/lib/dbus"
mount --bind -v /home/jannis/.config/pulse "${chroot_dir}/home/steam/.config/pulse"
touch "${chroot_dir}/home/steam/.pulse-cookie"
mount --bind /home/jannis/.pulse-cookie "${chroot_dir}/home/steam/.pulse-cookie"
mount -vR /tmp "${chroot_dir}/tmp"
mount -vR /dev/shm "${chroot_dir}/dev/shm"

mount -vR /usr/src/linux "${chroot_dir}/usr/src/linux"

# mount the game directory
mount -v $game_part "${chroot_dir}/games"

# chroot, substitute user, and start steam
"${chroot_arch}" chroot "${chroot_dir}" su -c 'XDG_RUNTIME_DIR=/run/user/1000 swallow steam' steam

# unmount the chroot directories when steam exits
umount -vl "${chroot_dir}/proc"
umount -vl "${chroot_dir}/sys"
umount -vl "${chroot_dir}/dev"
umount -vl "${chroot_dir}/run"
umount -vl "${chroot_dir}/var/db/repos/gentoo"

umount -vl "${chroot_dir}/var/lib/dbus"
umount -vl "${chroot_dir}/tmp"
umount -vl "${chroot_dir}/dev/shm"
umount -vl "${chroot_dir}/home/steam/.config/pulse"
umount -vl "${chroot_dir}/home/steam/.pulse-cookie"

umount -vl "${chroot_dir}/usr/src/linux"

# unmount the game directory
umount -v "${chroot_dir}/games"

xhost -local:
