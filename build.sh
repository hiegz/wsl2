#!/bin/bash

set -eu

KERNELDIR=$PWD/WSL2-Linux-Kernel
KERNELVERSION=linux-msft-wsl-6.6.87.2

ZFSDIR=$PWD/zfs
ZFSVERSION=zfs-2.3.2

if [ ! -f "/etc/arch-release" ]; then
    echo "error: you must be running arch"
    echo "info:  quitting ..."
    exit 1
fi

sudo pacman -S --noconfirm --needed \
    base-devel \
    bc \
    flex \
    bison \
    pahole \
    openssl \
    libelf \
    cpio \
    qemu-base \
    gcc14 \
    python

test -d $KERNELDIR/.git || git clone --single-branch --branch $KERNELVERSION --depth 1 https://github.com/microsoft/WSL2-Linux-Kernel $KERNELDIR
cd $KERNELDIR
git pull origin $KERNELVERSION
git reset --hard $KERNELVERSION
cp Microsoft/config-wsl .config
make olddefconfig
make prepare
make scripts

test -d $ZFSDIR/.git || git clone --single-branch --branch $ZFSVERSION --depth 1 https://github.com/openzfs/zfs $ZFSDIR
cd $ZFSDIR
git pull origin $ZFSVERSION
git reset --hard $ZFSVERSION
sh autogen.sh
./configure \
    --prefix=/ \
    --libdir=/lib \
    --includedir=/usr/include \
    --datarootdir=/usr/share \
    --enable-linux-builtin=yes \
    --with-linux=$KERNELDIR \
    --with-linux-obj=$KERNELDIR \
    --enable-systemd
./copy-builtin $KERNELDIR
make -j$(nproc)
sudo make install
sudo ldconfig

cd $KERNELDIR
echo "CONFIG_USB_STORAGE=y" >>.config
echo "CONFIG_DM_CRYPT=y" >>.config
echo "CONFIG_ZFS=y" >>.config
make -j$(nproc) CC=gcc-14
sudo make modules_install
