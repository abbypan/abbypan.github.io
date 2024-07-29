---
layout: post
category: tech
title: "archlinux"
tagline: "kiss"
tags: [ "archlinux", "clonezilla" ] 
---
{% include JB/setup %}

* toc
{:toc}

# 制作启动u盘

下载[archlinux iso](http://www.archlinux.org/download/)

下载[ventoy](https://www.ventoy.net/)
    
刻录ventoy后，将ventoy分区格式化为ntfs。

直接将archlinux iso文件拷贝到ventoy分区。
    
还可以放入 [clonezilla iso](http://drbl.nchc.org.tw/clonezilla/clonezilla-live/download/), [gparted iso](https://gparted.org/livecd.php), [winpe iso](https://www.ibmnb.com/51pe/) 等其他iso。

## dd

linux 环境直接刻录u盘:

    dd bs=4M if=archlinux.iso of=/dev/sdx status=progress && sync

## windows

windows环境直接刻录u盘:

    下载LinuxLive USB Creator：http://www.linuxliveusb.com/

# 初始安装

[How to Install Arch Linux](https://itsfoss.com/install-arch-linux/)

[Arch Linux and Windows 10 (UEFI + Encrypted) Install Guide](https://octetz.com/docs/2020/2020-2-16-arch-windows-install/)

## u盘启动

进入BIOS，从U盘启动，进入archlinux live

## 设置arch源

编辑/etc/pacman.d/mirrorlist，选择合适的server

{% highlight bash %}
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
{% endhighlight %}

## 硬盘分区

假设系统硬盘为/dev/sda

### 全新分区

    fdisk /dev/sda

### 将磁盘旧的msdos分区表切换为gpt

    sgdisk -g /dev/sda

### 新建系统分区

{% highlight bash %}
mkfs -t ext4 -b 4096 -E stride=128,stripe-width=128 /dev/sda1
{% endhighlight %}

### 调整系统分区大小

    e2fsck -f /dev/sda1
    resize2fs /dev/sda1

### 新建efi分区 

磁盘新建一个efi分区（假设为 /dev/sda5），类型为vfat，标识为`boot, esp`，大小例如1GB

### /etc/fstab 示例

    /dev/sda1         	/	ext4      	rw,relatime,stripe=128	0 1
    /dev/sda5      	/boot         	vfat      	defaults 0 2

## 连接无线网絡

``wifi-menu``

[iwd](https://wiki.archlinux.org/index.php/Iwd_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

``iwctl --passphrase <passphrase> station <device> connect <SSID>``

## 安装系统

{% highlight bash %}
mount /dev/sda1 /mnt
mount /dev/sda5 /mnt/boot
pacstrap /mnt base base-devel dialog vim iwd
pacstrap /mnt linux linux-headers linux-firmware
pacstrap /mnt glibc lib32-glibc
arch-chroot /mnt
{% endhighlight %}

编辑/etc/pacman.d/mirrorlist，设置arch源，同上节

{% highlight bash %}
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
mkinitcpio -p linux
pacman -S netctl net-tools wpa_actiond wireless_tools wpa_supplicant ifplugd dialog dhclient dhcpcd
exit
reboot
{% endhighlight %}

## 系统更新

重启之后，执行``wifi-menu``连接到无线网络

{% highlight bash %}
pacman -Syu
{% endhighlight %}

## 数据包更新失败

{% highlight bash %}
sudo pacman -S archlinux-keyring  
sudo pacman-key --refresh-keys
sudo pacman-key --populate archlinux
sudo pacman -Scc
sudo pacman -Syu
{% endhighlight %}


## pacman/yaourt调用aria2多线程下载文件

假设同时开8个连接

    pacman -S aria2

在/etc/pacman.conf中指定

{% highlight bash %}
XferCommand = /usr/bin/aria2c -c -o %o %u
{% endhighlight %}

在/etc/makepkg.conf中指定DLAGENTS

{% highlight bash %}
'http::/usr/bin/aria2c -c -o %o %u'
'https::/usr/bin/aria2c -c -o %o %u'
'ftp::/usr/bin/aria2c -c -o %o %u'
{% endhighlight %}

## ntp时间同步

{% highlight bash %}
pacman -S ntp
ntpdate asia.pool.ntp.org
{% endhighlight %}

# UEFI 引导

## 配置 uefi Systemd-boot

[用Systemd-boot取代GRUB作為Linux的bootloader](https://ivonblog.com/posts/replace-grub-with-systemd-boot/)

### 安装

    pacman -S efibootmgr

### 安装/修复 EFI引导

    bootctl install

## 设置archlinux的EFI引导

blkid 查看 archlinux 根分区的PARTUUID。

编辑 /boot/loader/entries/arch.conf

    title Arch Linux
    linux	/vmlinuz-linux 
    initrd	/initramfs-linux.img
    options root=PARTUUID=xxxxxxxxxx rw quiet splash


## 添加windows的EFI引导

把windows系统分区下的EFI/Microsoft目录直接拷贝到/boot/EFI/目录下。

##  设置默认引导

编辑 /boot/loader/loader.conf

    default arch
    timeout 3
    console-mode max

## boot目录示例

    $ tree /boot -L 3
    /boot
    ├── EFI
    │   ├── Microsoft
    │   │   ├── Boot
    │   │   └── Recovery
    │   └── systemd
    │       └── systemd-bootx64.efi
    ├── initramfs-linux-fallback.img
    ├── initramfs-linux.img
    ├── loader
    │   ├── entries
    │   │   └── arch.conf
    │   ├── entries.srel
    │   ├── loader.conf
    │   └── random-seed
    └── vmlinuz-linux

## 调整efi boot项

设置boot优先顺序，例如先1再0：efibootmgr -o 1,0

删除某个boot项，例如3: efibootmgr -b 3 -B

# 图形界面

## 安装X 

{% highlight bash %}
pacman -S xorg xorg-xinit consolekit
{% endhighlight %}

### 安装XFCE

{% highlight bash %}
pacman -S xfce4 xfce4-goodies xfce4-notifyd elementary-xfce-icons
{% endhighlight %}

进入X的配置，不然关机键老是灰的：编辑~/.xinitrc

{% highlight bash %}
exec ck-launch-session dbus-launch startxfce4
{% endhighlight %}

# 硬件驱动

## 声卡

- [ArchWiki:设置ALSA](https://wiki.archlinux.org/index.php/ALSA_%E5%AE%89%E8%A3%85%E8%AE%BE%E7%BD%AE_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)
- [archlinux音量太小的问题解决](https://bbs.archlinux.org/viewtopic.php?pid=1090109)

{% highlight bash %}
# pacman -Sy pavucontrol pulseaudio pulseaudio-alsa alsa-lib alsa-utils alsa-oss
# gpasswd -a USERNAME wheel
# gpasswd -a USERNAME audio
# alsaconf
# alsamixer
# alsactl store
{% endhighlight %}

编辑 ``/etc/rc.conf`` 文件，添加 ``alsa`` 到DAEMONS行。

编辑``/etc/modprobe.d/alsa-base``文件，添加以下两行：

{% highlight bash %}
options snd-usb-audio index=0
options snd-hda-intel index=1
{% endhighlight %}

## 配置thinkpad声音热键

在 /usr/local/bin 中添加 sound.sh：

{% highlight bash %}
#!/bin/bash
# use PulseAudio

case "$1" in
  "up")
          pactl set-sink-mute 0 false ; pactl set-sink-volume 0 +5%
          ;;
  "down")
          pactl set-sink-mute 0 false ; pactl -- set-sink-volume 0 -5%
          ;;
  "mute")
          pactl set-sink-mute 0 toggle
          ;;
  "microphonemute")
          pactl set-source-mute 1 toggle
          ;;
  *)
          pactl set-sink-mute 0 false ; pactl -- set-sink-volume 0 $1%
esac

exit 0
{% endhighlight %}

thinkpad x1 carbon 2013 在 ~/.xbindkeysrc 中添加：

{% highlight bash %}
# Increase volume
"sound.sh up"  
    m:0x0 + c:123
    XF86AudioRaiseVolume

# Decrease volume
"sound.sh down"  
    m:0x0 + c:122
    XF86AudioLowerVolume

# Toggle mute
"sound.sh mute"  
    m:0x0 + c:121
    XF86AudioMute

# Toggle microphonemute
"sound.sh microphonemute"
    m:0x0 + c:198
    XF86AudioMicMute
{% endhighlight %}

thinkpad x1 carbon 2015  在 ~/.xbindkeysrc 中添加：

{% highlight bash %}
# Increase volume
"sound.sh up"  
    XF86WakeUp + F3

# Decrease volume
"sound.sh down"  
    XF86WakeUp + F2

# Toggle mute
"sound.sh mute"  
    XF86WakeUp + F1

# Toggle microphonemute
"sound.sh microphonemute"
    XF86WakeUp + F4
{% endhighlight %}

在~/.xinitrc中添加：``xbindkeys``

## 热插拔(xfce4)

{% highlight bash %}
pacman -S ntfs-3g thunar-volman udisks2
pacman -S gvfs gvfs-afc gvfs-gphoto2 gvfs-mtp
{% endhighlight %}

配置 /etc/fstab，手动挂载磁盘

{% highlight bash %}
/dev/sdb1 /mnt/usb ntfs-3g noauto,users,permissions 0 0
{% endhighlight %}

挂载示例： 

    $ udisksctl mount -b /dev/sdc1

## 显卡

    $ sudo pacman -S nvidia  nvidia-utils
    
## 触摸屏

    $ sudo pacman -S xf86-input-wacom

## 关闭触摸板

{% highlight bash %}
sudo pacman -S synaptics
sudo synclient TouchpadOff=1
{% endhighlight %}

# 输入法

{% highlight bash %}
pacman -S ibus-rime
{% endhighlight %}

在``$HOME/.bashrc``中添加：

{% highlight bash %}
export LANG="zh_CN.UTF-8"
export LC_CTYPE="zh_CN.UTF-8"
export XIM_PROGRAM=ibus
export XMODIFIERS="@im=ibus"
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XIM=ibus
{% endhighlight %}

在``$HOME/.xinitrc``中添加：

    ibus-daemon -drx

## 郑码

    $ git clone https://github.com/rime/plum
    $ cd plum 
    $ bash rime-install lotem/rime-zhengma

编辑 ``~/.config/ibus/rime/default.custom.yaml``：

    patch:
      schema_list:
        - schema: zhengma
        - schema: terra_pinyin

# 中文环境

- ``vim /etc/locale.gen``，指定zh_CN.UTF-8
- ``vim /etc/local.conf``

{% highlight bash %}
LANG=zh_CN.UTF-8
LC_MESSAGES=zh_CN.UTF-8
{% endhighlight %}

- 执行locale-gen
- vim /etc/rc.conf

{% highlight bash %}
LOCALE=zh_CN.UTF-8
{% endhighlight %}

## locale-gen时找不到character map file

``pacman -Syu``升级的时候出的问题

执行locale-gen提示：``character map file "en_US" not found``

结果locale就变成"C"

``pacman -S glibc``重装一遍，还是出错，不过提示空间不足

``pacman -Scc`` 清理空间

``pacman -S glibc -f``


# 网络

## 根据MAC地址固定网卡名称

编辑文件/etc/udev/rules.d/10-network.rules

{% highlight bash %}
SUBSYSTEM=="net", ATTR{address}=="00:26:2d:f6:ad:43", NAME="eth0"
SUBSYSTEM=="net", ATTR{address}=="70:f1:a1:28:5a:ad", NAME="wlan0"
{% endhighlight %}

## 无线(netctl)
- 安装: ``pacman -S net-tools wireless_tools wpa_supplicant netctl``
- 配置: 参考/etc/netctl/examples/

- 新建一个/etc/netctl/athome配置(wpa)

``wpa_passphrase athome athomepasswd``查看psk，假设psk为``xxxxxxxxxxxxx``

{% highlight bash %}
CONNECTION='wireless'
DESCRIPTION='athome'
INTERFACE='wlan0'
SECURITY='wpa'
ESSID='athome'
IP='dhcp'
KEY=\"xxxxxxxxxxxxx
{% endhighlight %}


- 新建一个/etc/netctl/atwork配置(wep)

{% highlight bash %}
CONNECTION='wireless'
DESCRIPTION='atwork'
INTERFACE='wlan0'
SECURITY='wep'
ESSID=atwork
IP='dhcp'
KEY="s:myatworkpasswd"
{% endhighlight %}

- 开机启动

{% highlight bash %}
netctl enable athome
{% endhighlight %}

- 移除开机启动

{% highlight bash %}
ls /etc/systemd/system/multi-user.target.wants/
netctl enable athome
{% endhighlight %}

- 手工启动

{% highlight bash %}
netctl start athome
{% endhighlight %}

## 无线(wpa_supplicant)

安装

{% highlight bash %}
pacman -S net-tools wireless_tools wpa_supplicant
{% endhighlight %}

假设配置ESSID为mywireless，密码为mypasswd的无线

{% highlight bash %}
wpa_passphrase mywireless mypasswd >> /etc/wpa_supplicant/wpa_supplicant.conf
{% endhighlight %}

手动修改wpa_supplicant.conf

{% highlight bash %}
update_config=1
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
ap_scan=1
fast_reauth=1

network={
ssid="mywireless"

#proto=WPA
proto=RSN
key_mgmt=WPA-PSK
pairwise=CCMP TKIP
group=CCMP TKIP

#psk="mypasswd"
psk=09896d6dc939e1d6b279c10ee3d4d1c8c75970ce345c6552b7ee47d892f0740e
}
{% endhighlight %}

手动连接：假设无线网卡为wlan0

{% highlight bash %}
WLAN=wlan0
ESSID=mywireless
PASSWD=mypasswd

rm /run/dhcpcd-$WLAN.pid
rm /var/run/wpa_supplicant/$WLAN

ifconfig $WLAN up

wpa_supplicant -dd -B -Dwext -i $WLAN -c /etc/wpa_supplicant.conf

ifconfig $WLAN up
iwconfig $WLAN essid $ESSID key "s:$PASSWD"
dhcpcd $WLAN
{% endhighlight %}


## vpn
- 参考：[archlinux pptp vpn拨号连接](http://blog.vkill.net/read.php?97)
- 没看到arch下有/etc/ppp/ip-up.d目录，用以下脚本来启动vpn，我没有把它加为开机启动项，嗯。

{% highlight bash %}
#!/bin/zsh

#取网关地址
gateway=`route|grep default|grep eth0|awk '{print $2;}'`
vpn_gateway="192.168.6.253"

echo "拨号..."
sudo poff -a
sleep 2
sudo pon lab
sleep 3

echo "修改路由..."
#科大的地址不从vpn走
sudo route add -net 202.38.0.0/16 gw $gateway eth0
sudo route add -net 210.45.0.0/16 gw $gateway eth0
sudo route add -net 211.86.0.0/16 gw $gateway eth0

#默认从vpn走
sudo route del default
sudo route add default gw $vpn_gateway dev ppp0

#看路由
sudo route -n
{% endhighlight %}

##  netctl提示wpa无线连接失败，要看 journal -xn等等

{% highlight bash %}
netctl start somewireless
{% endhighlight %}

netctl 提示wpa无线连接失败，要看journal -xn等等

可以先禁用对应的网卡，再重新start，例如：

{% highlight bash %}
ip link set wlan0 down
netctl start somewireless
{% endhighlight %}

## 无线速度慢 wireless slow

参考[Slow Wireless Intel 6235 (iwlwifi module)](https://bbs.archlinux.org/viewtopic.php?id=146518)

{% highlight bash %}
echo options iwlwifi 11n_disable=1 | sudo tee /etc/modprobe.d/51-disable-6235-11n.conf 
{% endhighlight %}

## 禁用 wifi 键盘灯 LED 闪烁

见：[wireless led blink](https://wiki.archlinux.org/index.php/Wireless_Setup_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29#.E7.A6.81.E7.94.A8_LED_.E9.97.AA.E7.83.81)

{% highlight bash %}
# echo 'options iwlwifi led_mode=1' >> /etc/modprobe.d/wlan.conf
# modprobe -r iwlwifi && modprobe iwlwifi
{% endhighlight %}
或者
{% highlight bash %}
# echo 'w /sys/class/leds/phy0-led/trigger - - - - phy0radio' > /etc/tmpfiles.d/phy0-led.conf
# systemd-tmpfiles --create phy0-led.conf
{% endhighlight %}


# 常用软件

{% highlight bash %}
pacman -S rsync curl lftp wget axel
pacman -S wqy-bitmapfont wqy-zenhei ttf-monaco
pacman -S smplayer ffmpeg flashplayer
pacman -S libreoffice-zh-CN libreoffice-impress libreoffice-writer libreoffice-calc 
pacman -S zip unzip unrar p7zip thunar-archive-plugin xarchiver arj cpio lzop
pacman -S firefox firefox-i18n-zh-cn freshplayerplugin pepper-flash chromium
pacman -S dnsutils traceroute wireshark-gtk
{% endhighlight %}

## yay

    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si

## 安装deb包

    yay -S debtap
    sudo debtap -u
    debtap xxx.deb
    sudo pacman -U xxx.zst

## Web: NGINX+PHP

{% highlight bash %}
pacman -S nginx spawn-fcgi php-cgi
{% endhighlight %}

- 以http(用户):http(组)启动fastcgi : 

{% highlight bash %}
spawn-fcgi -a 127.0.0.1 -p 9000 -C 5 -u http -g http -f /usr/bin/php-cgi
{% endhighlight %}

- 配置/etc/nginx/conf/nginx.conf

{% highlight bash %}
location / {
root   /var/www;
index  index.php index.html index.htm;
}

location ~ \.php$ {
root           /var/www;
fastcgi_pass   127.0.0.1:9000;
fastcgi_index  index.php;
fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
include        fastcgi_params;
}
{% endhighlight %}

- 启动nginx: /etc/rc.d/nginx start

## music

[cue_splitting](https://wiki.archlinux.org/index.php/CUE_Splitting)

{% highlight bash %}
pacman -S cuetools mp3info wavpack flac mac shntool bchunk
{% endhighlight %}

## firefox 安装 flash 插件

- 在 adobe 网站下载 flash player
- 将其中的libflashplayer.so 复制到 ~/.mozilla/plugins/目录下
- 执行 ldd ~/.mozilla/plugins/libflashplayer.so 

## virtualbox

参考： [Install VirtualBox on Arch Linux](https://linuxhint.com/install-virtualbox-arch-linux/)

    bios -> cpu 设置 -> 打开 amd-v

    pacman -S virtualbox  选择 virtualbox-host-modules-arch

    reboot

    modprobe vboxdrv

    yay -S virtualbox-ext-oracle
    
    usermod -G vboxusers -a [username]

## java

查看支持的java版本：

    archlinux-java status

切换java的版本：

    archlinux-java set <JAVA_ENV_NAME>

## 系统备份

使用 [clonezilla](http://drbl.nchc.org.tw/clonezilla/clonezilla-live/download/) 备份/恢复 磁盘或分区

# 故障处理

## KERNEL PANIC 恢复

- 系统升级失败，重启提示kernel panic，switch_root : fail to ...
- 从live cd启动，将原来系统的根分区挂载到/mnt下，再用旧版glibc恢复

{% highlight bash %}
mount /dev/sda1 /mnt
pacman -U glibc-2.16.0-1-x86_64.pkg.tar.xz -r /mnt
{% endhighlight %}


## /bin/plymouth: No such file or directory

archlinux , thinkpad x61t，开机出错

journalctl -xn显示 /bin/plymouth: No such file or directory 

删掉 /etc/fstab 中不存在的介质

## 闪屏 

thinkpad x12 detachable, intel cpu, 闪屏

[Screen_flickering](https://wiki.archlinux.org/title/Intel_graphics#Screen_flickering)

arch.conf开机引导的options项中添加`i915.enable_psr=0`
