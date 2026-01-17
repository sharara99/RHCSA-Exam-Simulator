# RHCSA Exam Answers

## Node1.example.com

### Q1: Configure TCP/IP and Hostname

**Requirements:**
- Hostname: node1.domain.example.com
- IP Address: 192.168.71.240
- Netmask: 255.255.255.0
- Gateway: 192.168.71.2
- DNS: 192.168.71.2

**Solution:**
```bash
hostnamectl set-hostname node1.domain.example.com
nmcli con show  # Find the connection name (e.g., ens160)
nmcli con mod ens160 ipv4 192.168.71.240/24 ipv4.gateway 192.168.71.2 ipv4.dns 192.168.71.2
nmcli con up ens160
```

**Note:** If `nmcli` is not available, use `nmtui` instead.

**Verification:**
```bash
ifconfig
cat /etc/resolv.conf
```

---

### Q2: Configure Red Hat VM Repository

**Requirements:**
- BaseOS url: http://content.example.com/rhel9/x86_64/dvd/BaseOS
- AppStream url: http://content.example.com/rhel9/x86_64/dvd/AppStream

**Solution:**
```bash
vi /etc/yum.repos.d/yum.repo
```

Add the following content:
```ini
[Server-1]
name=baseos
baseurl=http://content.example.com/rhel9/x86_64/dvd/BaseOS
enabled=1
gpgcheck=0

[Server-2]
name=appstream
baseurl=http://content.example.com/rhel9/x86_64/dvd/AppStream
enabled=1
gpgcheck=0
```

**Verification:**
```bash
yum clean all
yum update
yum repolist
```

---

### Q3: Debug SELinux

**Requirements:**
- Web server running on non-standard port "82" is having issues serving content
- The web server can serve all the existing HTML files from `/var/www/html`
- Don't make any changes to these files
- Web service should automatically start at boot time

**Solution:**
```bash
# Check if SELinux is enforced
getenforce  # Should show "Enforcing"

# Check if httpd is installed
rpm -qa | grep httpd

# Check firewalld
firewall-cmd --list-all

# Add firewall rules if needed
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-port=82/tcp
firewall-cmd --reload

# Verify firewall configuration
firewall-cmd --list-all

# Check SELinux port configuration
semanage port -l | grep "http"

# Add port 82 to SELinux http_port_t
semanage port -a -t http_port_t -p tcp 82

# Start and enable httpd service
systemctl start httpd.service
systemctl enable httpd.service

# Verify SELinux configuration
semanage port -l | grep "http"  # Should show port 82
```

**Verification:**
- Open Firefox browser and type: `node1.domain.example.com:82` or `http://<ipaddress>:82`
- You should see: "This is my web server."
- Or use: `curl node1.domain.example.com:82`

---

### Q4: Create Users, Groups, and Group Membership

**Requirements:**
- A group named `adminuser`
- A user "harry" who belongs to `adminuser` as a secondary group
- A user "natasha" who belongs to `adminuser` as a secondary group
- A user "sarah" who doesn't have access to an interactive shell and who is not a member of `adminuser` group
- All users should have the password of "centtered"

**Solution:**
```bash
groupadd adminuser
useradd -G adminuser harry
useradd -G adminuser natasha
useradd -s /sbin/nologin sarah
passwd harry  # Enter password: centtered
passwd natasha  # Enter password: centtered
passwd sarah  # Enter password: centtered
```

**Verification:**
```bash
cat /etc/passwd
# Should show:
# harry:x:1001:1002::/home/harry:/bin/bash
# natasha:x:1002:1003::/home/natasha:/bin/bash
# sarah:x:1003:1004::/home/sarah:/sbin/nologin
```

---

### Q5: Cron Job

**Requirements:**
- Configure a cron job for the user "natasha" that runs daily every 14:23 minute local time executes "Ex200 is processing" with logger
- Configure a cron job for the user "natasha" that runs daily every 1-minute local time executes "Ex200 is processing" with logger

**Solution:**
```bash
crontab -e -u natasha
```

Add the following lines:
```
23 14 * * * echo "Ex200 is processing."
*/1 * * * * echo "Ex200 is processing."
```

```bash
systemctl restart crond.service
```

**Verification:**
```bash
tail -f /var/log/cron
```

---

### Q6: Create a Collaborative Directory

**Requirements:**
- Create a directory `/home/admin` with the following characteristics
- Group ownership of `/home/admin` is `adminuser`
- The directory should be readable, writable, and accessible to member of `adminuser`, but not any other user
- Files created in `/home/admin` automatically have group ownership set to the `adminuser` group

**Solution:**
```bash
mkdir /home/admin
chgrp adminuser /home/admin
chmod 2770 /home/admin  # 2 = setgid bit, 770 = rwx for owner and group
```

**Verification:**
```bash
cd /home/admin
touch file1
mkdir dir1
ls -l  # Verify group ownership is adminuser
```

---

### Q7: Create User 'alex' with Specific UID

**Requirements:**
- Create user 'alex' with 3456 uid and set password to "centtered"

**Solution:**
```bash
useradd -u 3456 alex
passwd alex  # Enter password: centtered
```

**Verification:**
```bash
id alex  # Should show uid=3456
```

---

### Q8: Locate and Copy Files

**Requirements:**
- Locate all the files owned by user "natasha" and copy them under `/root/locatedfiles`

**Solution:**
```bash
mkdir /root/locatedfiles
find / -user natasha -type f -exec cp -rvp {} /root/locatedfiles \;
```

**Verification:**
```bash
ls -l /root/locatedfiles
```

---

### Q9: Find String and Save to File

**Requirements:**
- Find a string 'strato' from `/usr/share/dict/words` and put it into `/root/lines` file

**Solution:**
```bash
cat /usr/share/dict/words | grep strato > /root/lines
```

**Verification:**
```bash
cat /root/lines
```

---

### Q10: Configure AutoFS

**Requirements:**
- Configure autofs to automount the home directories of remote users
- NFS export /home on your system
- System has preconfigured for remoteuser20
- remoteuser20 is exported on classroom.example.com(192.168.71.254):/home/remoteuser20
- remoteuser20 home directory should be automounted locally beneath /home as /home/remoteuser20
- home directories must be writable by their users

**Solution:**
```bash
# Install autofs and nfs packages (should be installed by default)
yum install autofs* nfs* -y

# Start and enable autofs service
systemctl start autofs
systemctl enable autofs

# Check available exports
showmount -e 192.168.71.254
# Output: /home/remoteuser20 (use the actual output)

# Create auto.master.d entry
vi /etc/auto.master.d/remoteuser.autofs
# Add: /home/remoteuser20 /etc/auto.remoteuser

# Create auto.remoteuser map file
vi /etc/auto.remoteuser
# Add: * -rw,sync,fstype=nfs4 192.168.71.254:/home/remoteuser20/&

# Restart autofs
systemctl restart autofs
```

**Verification:**
```bash
su - remoteuser20
cd
pwd  # Should be /home/remoteuser20
```

---

### Q11: Create Archives

**Requirements:**
a. Create an archive `/root/backup.tar.bz2` of `/usr/local` directory and compress it with bzip2
b. Create an archive `/root/myetcbackup.tgz` of `/etc` directory

**Solution:**
```bash
# Part a: Create tar.bz2 archive
tar -cvf /root/backup.tar /usr/local
bzip2 /root/backup.tar

# Part b: Create tgz archive
tar -czvf /root/myetcbackup.tgz /etc
```

**Verification:**
```bash
ls -l /root/backup.tar.bz2
ls -l /root/myetcbackup.tgz
```

---

### Q12: Create Container for alth User

**Requirements:**
- Use this link: http://domain.exam.com/rhel9/Containerfile build image named monitor
- Don't change anything in Container file

**Solution:**
```bash
ssh alth@localhost
wget http://domain.exam.com/rhel9/Containerfile
podman build -t monitor -f Containerfile
```

**Verification:**
```bash
podman images | grep monitor
```

---

### Q13: Create Rootless Container

**Requirements:**
- Create a container name asciipdf
- Use monitor image for asciipdf which you previously created
- Create a system service named container-asciipdf for alth user only
- Service will automatically started across reboot
- Local directory /opt/files attached to container directory /opt/incoming
- Local directory /opt/processed attached to container directory /opt/outgoing
- If the service work properly, when you place any plain text file in /opt/files, then this file automatically converted into pdf and also placed under /opt/processed

**Solution:**
```bash
# As root: Create directories and set ownership
mkdir /opt/files /opt/processed
chown alth:alth /opt/files /opt/processed

# Switch to alth user
ssh alth@localhost

# Enable linger for user services
loginctl enable-linger

# Create and run container
podman run -d --name ascii2pdf -v /opt/files:/opt/incoming:z -v /opt/processed:/opt/outgoing:z monitor

# Verify container is running
podman ps

# Generate systemd service files
mkdir -p .config/systemd/user
cd .config/systemd/user
podman generate systemd --name ascii2pdf --files --new

# Reload and start service
systemctl --user daemon-reload
systemctl --user start container-ascii2pdf.service
systemctl --user enable container-ascii2pdf.service

exit
```

**Verification:**
```bash
# As root: Create test file
touch /opt/files/testfile
# File should appear as PDF in /opt/processed
```

---

### Q14: Make a Simple Script

**Requirements:**
- Create myscript file to locate all files under /usr/ of less than 10MB with permissions user identifier (SGID)
- Save all these files in list /root/script
- Copy script file in /usr/local/bin
- Make sure that the script run at any location

**Solution:**
```bash
vi /usr/local/bin/myscript.sh
```

Add the following content:
```bash
#!/bin/bash
find /usr -size -10M -type f -perm -2000 -exec ls -ltr {} \; > /root/script
```

```bash
chmod 2775 /usr/local/bin/myscript.sh
```

**Verification:**
```bash
cd /tmp
myscript.sh
cat /root/script
```

---

### Q15: Synchronize Time

**Requirements:**
- Synchronize the time of your system from "3.asia.ntp.org"

**Solution:**
```bash
# Check if chrony is installed
rpm -qa | grep chrony

# Check chronyd service status
systemctl status chronyd.service

# Start and enable chronyd service
systemctl start chronyd.service
systemctl enable chronyd.service

# Edit chrony configuration
vi /etc/chrony.conf
# Add: server 3.asia.ntp.org iburst

# Restart chronyd service
systemctl restart chronyd.service
```

**Verification:**
```bash
chronyc sources -v
```

---

### Q16: Set Permissions and Policies

**Requirements:**
a. All the new creating files for user "natasha" as -r-- --- --- as default permission
b. All the new creating directories for user "natasha" as dr-x --- --- as default permission
c. Set the password expire date: The password for all new users in 1st server should expires after 20 days
d. Assign sudo Privilege: Assign the sudo Privilege for Group "adminuser" and Group members can administrate without any password

**Solution:**
```bash
# Part a and b: Set umask for natasha
echo "umask 277" >> /home/natasha/.bashrc

# Part c: Set password expiration
vi /etc/login.defs
# Set: PASS_MAX_DAYS 20

# Part d: Configure sudo for adminuser group
visudo
# Add under # %wheel ALL=(ALL) NOPASSWD: ALL:
%adminuser ALL=(ALL) NOPASSWD: ALL
```

**Verification:**
```bash
# For umask
su - natasha
umask  # Should show 277
cd /home/natasha
mkdir dir1
touch file1
ls -l  # Verify permissions

# For password expiration
grep PASS_MAX_DAYS /etc/login.defs

# For sudo
grep adminuser /etc/sudoers
```

---

## Node2.example.com

### Q17: Reset Root Password

**Requirements:**
- Reset root password and make it "centtered"
- You should take care to enter the GRUB mode of the Rescue part and not from the default part

**Solution:**
1. Reboot the system
2. Interrupt the boot-loader countdown by pressing any key, except Enter
3. Move the cursor to the rescue kernel entry to boot (the one with the word rescue in its name)
4. Press `e` to edit the selected entry
5. Move the cursor to the kernel command line (the line that starts with Linux)
6. Move with the right arrow from there until you find "ro" and replace it with "rw init=/sysroot/bin/sh"
7. Hit `Ctrl + x`
8. Hit enter when it asks for a password without typing any passwords (exam environment only)
9. Chroot /sysroot
10. Passwd root (enter new password: centtered)
11. Touch /.autorelabel
12. Exit
13. Reboot

**Verification:**
```bash
# After reboot, login as root with password "centtered"
```

---

### Q18: Configure Red Hat VM Repository

**Requirements:**
- BaseOS url: http://domain10.example.com/rhel9/x86_64/dvd/BaseOS
- AppStream url: http://domain10.example.com/rhel9/x86_64/dvd/AppStream

**Solution:**
```bash
cd /etc/yum.repos.d
vi yum.repo
```

Add the following content:
```ini
[Server-1]
name=baseos
baseurl=http://domain10.example.com/rhel9/x86_64/dvd/BaseOS
enabled=1
gpgcheck=0

[Server-2]
name=appstream
baseurl=http://domain10.example.com/rhel9/x86_64/dvd/AppStream
enabled=1
gpgcheck=0
```

**Verification:**
```bash
yum repolist
yum clean all
yum update
```

---

### Q19: Resize Logical Volume

**Requirements:**
- Resize the logical volume name lv to 300 MB
- Make sure in lv volume have some data, data should not be affected by resizing
- Do not remove or modify /etc/fstab

**Solution:**
```bash
# Check current LV size
lvs
vgs
lvdisplay

# Extend logical volume (assuming current size is 76MB, need to add 224MB)
lvextend -L +224M /dev/vg/lv
# Or extend to exactly 300MB: lvextend -L 300M /dev/vg/lv

# Check filesystem type
blkid /dev/mapper/vg-lv

# Resize filesystem (for ext4)
resize2fs /dev/vg/lv
```

**Verification:**
```bash
df -h
lvs
lvdisplay
```

---

### Q20: Add Swap Partition

**Requirements:**
- Add a swap partition of 715MB and mount it permanently

**Solution:**
```bash
# List available disks
fdisk -l

# Create partition on /dev/vdb
fdisk /dev/vdb
# Press: p (print partition table)
# Press: m (for help)
# Press: n (new partition)
# Press: Enter (default partition number)
# Press: Enter (default first sector)
# Type: +715M
# Press: t (change partition type)
# Type: 2 (partition number)
# Press: l (list partition types)
# Type: 82 (Linux swap)
# Press: p (verify)
# Press: w (write and exit)

# Create swap
mkswap /dev/vdb2

# Add to /etc/fstab
vi /etc/fstab
# Add: /dev/vdb2 swap swap defaults 0 0

# Activate swap
mount -a
swapon -a
```

**Verification:**
```bash
free -m
swapon -s
# Reboot and verify again
init 6
free -m
swapon -s
```

---

### Q21: Create Logical Volume

**Requirements:**
- Create a logical volume "database" by using 50 PEs from the volume group "datastore"
- Consider that each PE size of volume group as "16MB"
- Format with ext3 filesystem and mount permanently under /mnt/database

**Solution:**
```bash
# List available disks
fdisk -l

# Create partition (need at least 800MB for 50 PEs * 16MB)
fdisk /dev/vdb
# Press: m (for help)
# Press: n (new partition)
# Press: Enter (default partition number)
# Press: Enter (default first sector)
# Type: +1024M
# Press: p (print)
# Press: t (change partition type)
# Type: 3 (partition number)
# Press: l (list types)
# Type: 8E (Linux LVM)
# Press: w (write)

# Create physical volume
pvcreate /dev/vdb3

# Create volume group with 16MB PE size
vgcreate -s 16M datastore /dev/vdb3

# Create logical volume with 50 PEs
lvcreate -l 50 -n database datastore

# Create mount point
mkdir /mnt/database

# Format with ext3
mkfs.ext3 /dev/datastore/database

# Add to /etc/fstab
vi /etc/fstab
# Add: /dev/datastore/database /mnt/database ext3 defaults 0 0

# Mount
mount -a
```

**Verification:**
```bash
df -h
# Reboot and verify
init 6
df -h
```

---

### Q22: Configure Recommended Tuned Profile

**Requirements:**
- Configure recommended tuned profile

**Solution:**
```bash
# Check if tuned is installed
rpm -qa | grep tuned

# Check tuned service status
systemctl status tuned.service

# Start and enable tuned service
systemctl start tuned.service
systemctl enable tuned.service

# List available profiles
tuned-adm list

# Check active profile
tuned-adm active

# Get recommended profile
tuned-adm recommend

# Set recommended profile (example: virtual-host)
tuned-adm profile virtual-host
```

**Verification:**
```bash
tuned-adm active
```
