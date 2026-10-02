# Boot splash screen with Plymouth

Replace the scrolling boot text with a graphical splash screen. Every step needs root.

This guide fits this machine's setup: systemd-boot booting a signed unified kernel image (UKI) at
`/boot/EFI/Linux/arch-linux.efi`, mkinitcpio with the `systemd` hook, Secure Boot keys managed by
sbctl, an `amdgpu` GPU, and a LUKS-encrypted root found through GPT partition auto-discovery.

The whole job takes four changes:

1. Install Plymouth, the program that draws the splash.
2. Add it to the initramfs (the small early-boot system built into the boot image).
3. Add `quiet splash` to the kernel command line.
4. Rebuild the UKI.

## The kernel command line comes from the install ISO

Before this change, `/proc/cmdline` looked like this:

```
initrd=\arch\boot\x86_64\initramfs-linux.img archisobasedir=arch archisosearchuuid=2026-08-17-...
```

These options came from the Arch install ISO. When neither `/etc/kernel/cmdline` nor
`/etc/cmdline.d/` exists, mkinitcpio copies `/proc/cmdline` into the UKI it builds. The first UKI
was built from the live ISO, and every rebuild since has copied those leftover options forward.
They do nothing on the installed system. It boots anyway because systemd finds the root partition
automatically (its partition type is "Linux root (x86-64)").

Step 3 creates a real command-line file, which replaces the ISO leftovers.

## Step 0: Enable the fallback image

The mkinitcpio preset builds no "fallback" image, and Secure Boot stops you editing the command line
from the boot menu, so turn the fallback on as a safety net. Give it its own frozen config and
command line, so the changes below never reach it:

```sh
sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio-fallback.conf
echo 'rw' | sudo tee /etc/kernel/cmdline-fallback
```

Make the copy now, before step 2 edits `/etc/mkinitcpio.conf`. Then, in
`/etc/mkinitcpio.d/linux.preset`, change these lines:

```sh
PRESETS=('default' 'fallback')

fallback_config="/etc/mkinitcpio-fallback.conf"
fallback_uki="/boot/EFI/Linux/arch-linux-fallback.efi"
fallback_options="-S autodetect --cmdline /etc/kernel/cmdline-fallback"
```

- `fallback_config` builds the fallback from the pre-Plymouth hooks, whatever later happens to
  `/etc/mkinitcpio.conf`.
- `--cmdline` embeds the fallback's own command line instead of the one from step 3, so it boots
  with full text output (no `quiet` or `splash`).
- `-S autodetect` skips the `autodetect` hook, which includes every module rather than only the
  ones this hardware uses.
- The stock commented-out `fallback_uki` points at `/efi`, but this machine's ESP is `/boot`.

The fallback is built by `mkinitcpio -P` in step 5, alongside the main image, and again with every
kernel update, so it never falls behind the installed kernel. Only edits to its own two files change
it. sbctl's mkinitcpio hook signs every UKI it builds, so the fallback works with Secure Boot.
systemd-boot automatically lists every `.efi` file in `/boot/EFI/Linux/`, so it appears as its own
boot menu entry. If the new image doesn't boot, hold **Space** at power-on to open the menu and pick
the fallback.

## Step 1: Install Plymouth

```sh
sudo pacman -S plymouth
```

## Step 2: Add the hook to `/etc/mkinitcpio.conf`

Change the `HOOKS` line to:

```
HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)
```

- The `plymouth` hook must come **after `systemd`** and **before `sd-encrypt`**. That order makes
  the LUKS passphrase prompt appear on the splash screen instead of as text.
- The `kms` hook loads `amdgpu` early, which Plymouth needs to draw graphics. It's already present.

## Step 3: Create a kernel command line

```sh
sudo mkdir /etc/cmdline.d
echo 'rw quiet splash' | sudo tee /etc/cmdline.d/root.conf
```

- `quiet` hides kernel messages, and `splash` tells Plymouth to show graphics.
- `rw` mounts root read-write. Arch normally uses it, and it's harmless here.
- Optionally, add `loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0` to hide stray
  messages and the blinking cursor.

No `root=` or `rd.luks...` options are needed, because root is discovered automatically.

## Step 4 (optional): Pick a theme

```sh
plymouth-set-default-theme -l     # list installed themes
```

The default on Arch is `bgrt`, which shows the Framework logo from the firmware with a spinner. To
change it, edit `/etc/plymouth/plymouthd.conf`:

```ini
[Daemon]
Theme=spinner
```

The theme is copied into the initramfs, so rebuild (step 5) after every theme change. More themes
are on the AUR (search `plymouth-theme`).

## Step 5: Rebuild and check the signature

```sh
sudo mkinitcpio -P
sudo sbctl verify
```

Make sure the rebuild output shows no errors and contains a line about the `plymouth` hook. sbctl
installs a hook that re-signs the UKI automatically after a rebuild. Still, check that
`sbctl verify` shows both `/boot/EFI/Linux/arch-linux.efi` and
`/boot/EFI/Linux/arch-linux-fallback.efi` as signed before rebooting. If one isn't, run
`sudo sbctl sign -s` on it. With Secure Boot on, an unsigned image won't boot.

## Optional: Test before rebooting

From a text console (Ctrl+Alt+F3, log in):

```sh
sudo plymouthd; sudo plymouth --show-splash; sleep 5; sudo plymouth --quit
```

## If something goes wrong

- **Black screen or no splash, but it still boots:** check `journalctl -b | grep -i plymouth`.
  Usually the hook is in the wrong place or `splash` is missing from the command line.
- **Won't boot at all:** pick `arch-linux-fallback` from the systemd-boot menu (hold Space), then
  undo the changes and run `mkinitcpio -P` again.
- **Neither image boots:** boot the Arch ISO, unlock the drive with
  `cryptsetup open /dev/nvme1n1p2 root`, mount it and `/boot`, then `arch-chroot` in and undo the
  changes.

## Hiding the boot menu

The systemd-boot menu and the firmware logo may still show briefly before the splash. To hide the
menu, set `timeout 0` in `/boot/loader/loader.conf`. Holding Space at power-on still opens it.
