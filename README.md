# gentooScript

This is a Gentoo configuration script for building Gentoo. The script follows what is instructed at Gentoo.com for amd_64 systems.
 Instead of building the kernel by hand, the script uses genkernel to install the kernel automatically.
 You might want to change the password on the script depending on your preferences. Also hostname and hosts files should be altered depending on your hostname.
 If you want to change things in your build after the compiling is done, you can re enter the chroot environment by mounting the root filesystem /dev/sda4 into /mnt/gentoo and mount chroot dependencies. Don't forget to unmount the File Systems after you are done.
 Don't leave other shells chrooted in the background since they won't let your system unmount itself and will give message as mount point busy.
 
 Steps to get the code in your VMs:
 
 Get the raw address of the gentooInstallScript.
 In your VM, without the commas, type wget 'yourrawaddress'.
 To shorten the URL you might want to use a tool like URL shortener.
 Then do chmod +x yourrawaddress.
./yourrawaddress to runn the script.