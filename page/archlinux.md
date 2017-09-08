---
layout: page
title: "archlinux"
tagline: "kiss"
---
{% include JB/setup %}

* toc
{:toc}

# 初始安装

下载archlinux最新iso文件：http://www.archlinux.org/download/

可以制作成光盘，或U盘启动

## U盘启动

下载LinuxLive USB Creator：http://www.linuxliveusb.com/

用LinuxLive USB Creator制作可启动的USB盘

修改BIOS，从USB启动，进入archlinux

## 设置arch源

编辑/etc/pacman.conf

{% highlight bash %}
[archlinuxfr]
SigLevel = Optional TrustAll
Server = http://repo.archlinux.fr/$arch
{% endhighlight %}

编辑/etc/pacman.d/mirrorlist

{% highlight bash %}
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
{% endhighlight %}

## 硬盘分区

假设系统硬盘为/dev/sda，这边是SSD

执行fdisk /dev/sda进行分区，假设新建的系统分区为/dev/sda1

{% highlight bash %}
mkfs -t ext4 -b 4096 -E stride=128,stripe-width=128 /dev/sda1
{% endhighlight %}

## 安装系统

执行``wifi-menu``，连接合适的无线网络

编辑/etc/pacman.d/mirrorlist，选择合适的server，比如163.com的源就比较快

{% highlight bash %}
mount /dev/sda1 /mnt
pacstrap /mnt base base-devel
pacstrap /mnt grub-bios
genfstab -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
{% endhighlight %}

设置arch源，见上节

{% highlight bash %}
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
mkinitcpio -p linux
grub-install --no-floppy /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S net-tools wpa_actiond wireless_tools wpa_supplicant ifplugd dialog
exit
reboot
{% endhighlight %}

重启之后，执行``wifi-menu``连接到无线网络

## 系统更新

{% highlight bash %}
pacman -Syu
pacman -S yaourt aria2
{% endhighlight %}

## pacman/yaourt调用aria2多线程下载文件

假设同时开8个连接

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

## 时间

{% highlight bash %}
yaourt -S ntp
ntpdate asia.pool.ntp.org
{% endhighlight %}

# 图形界面

## 安装X 

{% highlight bash %}
yaourt -S xorg xorg-xinit consolekit
{% endhighlight %}

## 安装lxde

{% highlight bash %}
yaourt -S lxde openbox
{% endhighlight %}

编辑~/.xinitrc
    
{% highlight bash %}
exec lxsession
{% endhighlight %}

## 安装XFCE

{% highlight bash %}
yaourt -S xfce4 xfce4-notifyd
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
# pacman -Sy pulseaudio alsa-lib alsa-utils alsa-oss
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

在.xinitrc中添加：``xbindkeys``

## 热插拔(xfce4)

{% highlight bash %}
yaourt -S ntfs-3g thunar-volman udisks
yaourt -S gvfs gvfs-afc gvfs-gphoto2 gvfs-mtp
{% endhighlight %}

配置 /etc/fstab，手动挂载磁盘

{% highlight bash %}
/dev/sdb1 /mnt/usb ntfs-3g noauto,users,permissions 0 0
{% endhighlight %}

## 音乐处理

[cue_splitting](https://wiki.archlinux.org/index.php/CUE_Splitting)

{% highlight bash %}
sudo yaourt -S cuetools mp3info wavpack flac mac shntool bchunk
{% endhighlight %}

## 关闭触摸板

{% highlight bash %}
sudo pacman -S synaptics
sudo synclient TouchpadOff=1
{% endhighlight %}

# 输入法

以fcitx为例

{% highlight bash %}
yaourt -S fcitx fcitx-sunpinyin fcitx-table-extra
{% endhighlight %}

在``$HOME/.bashrc``中添加：

{% highlight bash %}
export LANG="zh_CN"
export LC_CTYPE="zh_CN"
export XIM_PROGRAM=fcitx
export XMODIFIERS=@im=fcitx
export GTK_IM_MODULE=fcitx
export XIM=fcitx
{% endhighlight %}

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


# 常用软件

{% highlight bash %}
yaourt -S rsync curl lftp wget axel
yaourt -S wqy-bitmapfont wqy-zenhei ttf-monaco
yaourt -S smplayer ffmpeg flashplayer
yaourt -S libreoffice-zh-CN libreoffice-impress libreoffice-writer libreoffice-calc 
yaourt -S unzip unrar p7zip
yaourt -S firefox firefox-i18n-zh-cn freshplayerplugin pepper-flash chromium
yaourt -S dnsutils traceroute wireshark-gtk
{% endhighlight %}

# 网络

## 根据MAC地址固定网卡名称

编辑文件/etc/udev/rules.d/10-network.rules

{% highlight bash %}
SUBSYSTEM=="net", ATTR{address}=="00:26:2d:f6:ad:43", NAME="eth0"
SUBSYSTEM=="net", ATTR{address}=="70:f1:a1:28:5a:ad", NAME="wlan0"
{% endhighlight %}

## 无线(netctl)
- 安装: ``yaourt -S net-tools wireless_tools wpa_supplicant netctl``
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

- 手工启动

{% highlight bash %}
netctl start athome
{% endhighlight %}

## 无线(wpa_supplicant)

安装

{% highlight bash %}
yaourt -S net-tools wireless_tools wpa_supplicant
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

# 其它

## NGINX+PHP

{% highlight bash %}
yaourt -S nginx spawn-fcgi php-cgi
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


## KERNEL PANIC 恢复

- 系统升级失败，重启提示kernel panic，switch_root : fail to ...
- 从live cd启动，将原来系统的根分区挂载到/mnt下，再用旧版glibc恢复之

{% highlight bash %}
mount /dev/sda1 /mnt
yaourt -U glibc-2.16.0-1-x86_64.pkg.tar.xz -r /mnt
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


## firefox 安装 flash 插件

- 在 adobe 网站下载 flash player
- 将其中的libflashplayer.so 复制到 ~/.mozilla/plugins/目录下
- 执行 ldd ~/.mozilla/plugins/libflashplayer.so 

## /bin/plymouth: No such file or directory
archlinux , thinkpad x61t，开机出错

journalctl -xn显示 /bin/plymouth: No such file or directory 

删掉 /etc/fstab 中不存在的介质就行了

## locale-gen时找不到character map file

``pacman -Syu``升级的时候出的问题

执行locale-gen提示：``character map file "en_US" not found``

结果locale就变成"C"

``pacman -S glibc``重装一遍，还是出错，不过提示空间不足

``pacman -Scc`` 清理空间

``pacman -S glibc -f``

## 手动设置grub2引导 windows 双系统

见：[Archlinux grub2 windows8 (windows7) win8 (win7) 引导设置](http://hi.baidu.com/flashgive/item/b05697120fbf84fc9d778a26)

查看windows系统所在分区，假设是 /dev/sda1，即``(hd0,msdos0)``

找出/dev/sda1的uuid：``sudo blkid /dev/sda1``，假设是xxxxxxxxxxxx

在/boot/grub/grub.cfg中添加

{% highlight bash %}
menuentry 'Windows' {
        load_video
        insmod gzio
        insmod part_msdos
        insmod ntfs
        set root='(hd0,msdos0)'
        search --no-floppy --fs-uuid --set=root xxxxxxxxxxxx
        chainloader +1
}
{% endhighlight %}

## 无线速度慢 wireless slow

参考[Slow Wireless Intel 6235 (iwlwifi module)](https://bbs.archlinux.org/viewtopic.php?id=146518)

{% highlight bash %}
echo options iwlwifi 11n_disable=1 | sudo tee /etc/modprobe.d/51-disable-6235-11n.conf 
{% endhighlight %}

## 数据包更新失败

{% highlight bash %}
sudo pacman-key --refresh-keys
sudo pacman-key --populate archlinux
sudo pacman -Scc
sudo pacman -Syu
{% endhighlight %}

