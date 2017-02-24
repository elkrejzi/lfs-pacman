if [ "${EUID}" -ne 0 ]
then
  echo "This script must be ran as root."
  exit 1
fi

export LFS=/mnt/lfs
export PKGBUILDS=/sources/pacman/pkgbuild
export BUILDDIR=/sources/build
export PKGBUILD_ID=5000

if [ ! -d "${LFS}/${PKGBUILDS}" ]
then
  echo "PKGBUILD root unavailable. Please adjust the variable"
  exit 1
fi

if [ ! -d "${LFS}/${BUILDDIR}" ]
then
  install -o ${PKGBUILD_ID} -g ${PKGBUILD_ID} -dm755 ${LFS}/${BUILDDIR}
fi

lfs_mount_virt() {
  mountpoint ${LFS}/dev 2>&1>/dev/null || mount --bind /dev ${LFS}/dev
  mountpoint ${LFS}/dev/pts 2>&1>/dev/null || mount --bind /dev/pts ${LFS}/dev/pts

  mountpoint ${LFS}/proc 2>&1>/dev/null || mount -t proc none ${LFS}/proc
  mountpoint ${LFS}/sys 2>&1>/dev/null || mount -t sysfs none ${LFS}/sys
}

lfs_umount_virt() {
  mountpoint ${LFS}/dev/pts 2>&1>/dev/null && umount ${LFS}/dev/pts
  mountpoint ${LFS}/dev 2>&1>/dev/null && umount ${LFS}/dev

  mountpoint ${LFS}/proc 2>&1>/dev/null && umount ${LFS}/proc
  mountpoint ${LFS}/sys 2>&1>/dev/null && umount ${LFS}/sys
}

lfs_chroot_exec_cmd() {
  local cmd=${1}

  chroot "$LFS" /tools/bin/env -i \
      HOME=/root                  \
      TERM="$TERM"                \
      PS1='\u:\w\$ '              \
      PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
      ${cmd}
}

lfs_chroot_build_temp() {
  local pkg=${1}
  local cmd="export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin; \
             pushd ${BUILDDIR}/${pkg}; \
             /tools/bin/makepkg -f; \
             popd"

  rm -rf ${LFS}/${BUILDDIR}//+${pkg}

  cp -a ${LFS}/${PKGBUILDS}/${pkg} ${LFS}/${BUILDDIR}
  chown -R ${PKGBUILD_ID}:${PKGBUILD_ID} ${LFS}/${BUILDDIR}/${pkg}

  rm -rf ${LFS}/${BUILDDIR}/${pkg}/{pkg,src} ${LFS}/${BUILDDIR}/${pkg}/*.pkg.tar*

  chroot "$LFS" /tools/bin/env -i \
      HOME=${BUILDDIR}            \
      TERM="$TERM"                \
      PS1='\u:\w\$ '              \
      PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
      /tools/bin/su -pl pkgbuild -c "${cmd}"

  rm -rf ${LFS}/${BUILDDIR}/${pkg}/{pkg,src}
}

lfs_pacman_install_temp() {
  local pkg=${1}

  pushd ${LFS}/${BUILDDIR}/${pkg}
    for ff in *.pkg.tar*
    do
      case ${ff} in
        *-debug-[0-9]* )
        ;;
        * )
          PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin /tools/bin/pacman -U -r ${LFS} --noconfirm ${ff}
        ;;
      esac
    done
  popd
}
