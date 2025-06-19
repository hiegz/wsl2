# WSL2

Custom WSL2 kernel with zfs, dm_crypt, and usb mass storage enabled.

### Requirements

- Arch Linux
- WSL2
- `x86_64` architecture

### Build & Installation

In your WSL, run the following commands:

```
1. git clone https://github.com/hiegz/wsl2
2. cd wsl2
3. make
4. cp arch/x86_64/boot/bzImage /mnt/c/Users/<user>/bzImage
```

Stop the WSL2 instance if it is currently running:

```
wsl --shutdown
```

Include the following in the `.wslconfig` file in your Windows user's $HOME
directory:

```
[wsl2]
kernel=C:\\Users\\hiegz\\wsl\\bzImage
localhostForwarding=true
swap=0
```

If the file doesn't exists, just create it.
