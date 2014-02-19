---
layout: page
title: "Debian"
tagline: "安装笔记"
---
{% include JB/setup %}

## 安装

###  设置apt源 
- BIOS里选网络启动，重启，选debian网络安装； 
- 网络启动介绍见[PXE.USTC 基本文档](http://pxe.ustc.edu.cn)
- 也可以参考[硬盘安装说明 by lixuebai@ustc](http://mail.ustc.edu.cn/~lixuebai/GNU/DebianInstall.html)
- 手动输入源：``debian.ustc.edu.cn``；
- /etc/apt/source.list
   - ftp://debian.ustc.edu.cn/sources.list/
   - ``deb ftp://202.38.73.198/debian sid foo``


###  /etc/environment 

    LANG="zh_CN.UTF-8"
    LANGUAGE="zh_CN:zh"

###  /etc/fstab 

``/dev/sda1 /mnt/usb vfat user,rw,noauto,utf8=1,fmask=113,dmask=022,umask=022 0 0``


###  基础包 

``apt-get install build-essential``


## 网络

###  adsl 

- 主要参考这两个贴子：[adsl by Fly1945@Hiweed](http://linux.hiweed.com/node/2467)，[adsl配置 by ryang](http://ryang.68ab.com/debian.html#sec8)
- apt-get install pppoe
- 将/etc/network/interfaces中的相关内容注释掉
- /etc/ppp/peers/dsl-provider

        noipdefault
        usepeerdns
        defaultroute
        hide-password
        lcp-echo-interval 20
        lcp-echo-failure 3
        connect /bin/true
        noauth
        persist
        mtu 1492
        noaccomp
        default-asyncmap
        plugin rp-pppoe.so eth0
        #下边的xxx是adsl拨号时使用的用户名
        user "xxx"

- /etc/ppp/pap-secrets

        #下边的xxx是adsl拨号时使用的用户名，yyy是密码
        "xxx" dsl-provider "yyy" *

- pon dsl-provider
- 查错：plog



###  vpn 
- 主要参考这几个贴子
  - [VPN连接校园网 by kkk@ustc](http://bbs.ustc.edu.cn/cgi/bbscon?bn=Linux&fn=M3F936B98&num=2136)
  - [pptp-linux拨vpn by hacker ustc](http://bbs.ustc.edu.cn/cgi/bbscon?bn=Linux&fn=M454D58AB&num=2351)
  - [PPTP CLient by James Cameron](http://pptpclient.sourceforge.net/howto-debian.phtml)
  - [发一个让校内ip走vpn路由的perl脚本吧](http://bbs.ustc.edu.cn/cgi/bbstcon?board=Script&file=M.1211129882.A)
- apt-get install pptp-linux
- 设vpn连接名为$tunnel，连接的目标主机地址为$vpn_ip，用户名为$user，密码为$password
- /etc/ppp/options.pptp

        lock
        noauth
        nobsdcomp
        nodeflate
        nopcomp
        noaccomp
        noproxyarp

- /etc/ppp/peers/$tunnel

        pty "pptp $vpn_ip --nolaunchpppd"
        name $user
        remotename $tunnel
        file /etc/ppp/options.pptp
        ipparam $tunnel
        noauth
        persist
        linkname $tunnel
        nodefaultroute

- /etc/ppp/chap-secrets

       $user $tunnel $password *

- ``pon $tunnel debug dump logfd 2 nodetach``
- ifconfig查看ppp0的网关的ip为$vpn_gateway，之前的默认网关ip设为$gateway，如果网关经常变就在下面的脚本中搞成动态获取
- /etc/ppp/ip-up.d/$tunnel

{% highlight bash %}
#!/bin/bash

#动态获取原来网关的ip
gateway=`route|grep default|awk '{print $2;}'`

#默认从vpn走
route del default
route add default gw $vpn_gateway dev ppp0

#科大的地址不从vpn走
route add -net 202.38.0.0/16 gw $gateway dev eth0
route add -net 210.45.0.0/16 gw $gateway dev eth0
route add -net 211.86.0.0/16 gw $gateway dev eth0
{% endhighlight %}

### 无线
- 资料：
    - [CentrinoDriver輕鬆編譯](http://moto.debian.org.tw/viewtopic.php?t=7633&amp;start=0&amp;postdays=0&amp;postorder=asc&amp;highlight=&amp;sid=f3a3f4c96593f3a93781d49bcbca4a59)
    - [Wireless](http://ccl422.blogspot.com/2007/11/wireless.html)
    - [WPA_SUPPLICANT.CONF5](http://www.freebsd.org/cgi/man.cgi?query=wpa_supplicant.conf&amp;sektion=5)

- 环境

| 笔记本 | ASUS M2000  |
| ------ | ----------- |
| 系统 | Debian 2.6.22-3-686  |
| 无线网卡 |  Intel Pro/Wireless 2100  |
| ESSID | MyLab  |
| 用户名 | MyName  |
| 密码 | MyPasswd  |
| 网络验证 | WPA  |
| 数据加密 | TKIP  |
| EAP类型 | PEAP  |
| 验证方法 | EAP-MSCHAP V2  |

- 装驱动
 - 下载[ipw2100-fw](http://ipw2100.sourceforge.net/firmware.php)，解压到/lib/firmware目录下
 - rmmod ipw2100
 - modprobe ipw2100

- 查看/etc/udev/rules.d，找到ipw2100对应的eth1

        # PCI device 0x8086:0x1043 (ipw2100)
        SUBSYSTEM=="net", DRIVERS=="?\*", ATTR{address}=="xx:xx:xx:xx:xx:xx", NAME="eth1"


- 找接入的ap：
   - apt-get install wpasupplicant wireless-tools
   - iwlist eth1 scan

- 编辑/etc/wpa_supplicant/lab.conf

        ctrl_interface=/var/run/wpa_supplicant
        eapol_version=1
        ap_scan=1
        fast_reauth=1
        network={
        ssid="MyLab"
        id_str="wlab"
        scan_ssid=1
        key_mgmt=WPA-EAP
        eap=PEAP
        identity="MyName"
        password="MyPasswd"
        auth_alg=OPEN
        phase1="peaplabel=0"
        phase2="auth=MSCHAPV2"
        priority=10
        proto=WPA
        pairwise=TKIP
        group=TKIP
        }


- 测试一下：
``wpa_supplicant -w -i eth1 -D wext -c /etc/wpa_supplicant/lab.conf``

- 编辑/etc/network/interfaces：

        # 无线网卡
        allow-hotplug eth1
        iface eth1 inet dhcp
        wpa-driver wext
        wpa-roam /etc/wpa_supplicant/lab.conf
        ### 无线接入实验室
        wpa-ssid "MyLab"

- 启动无线：
``ifup eth1``


## grub

###  /boot/grub/menu.lst 

    title		Debian GNU/Linux, kernel 2.6.18-4-686
    root		(hd0,0)
    kernel		/boot/vmlinuz-2.6.18-4-686 root=/dev/hda1 ro
    initrd		/boot/initrd.img-2.6.18-4-686
    savedefault
    
    
    title		Microsoft Windows XP Professional
    root		(hd0,2)
    savedefault
    makeactive
    chainloader	+1

###  重装windows后修复linux 
- 作者是msygod@linuxsir，原帖在[这里](http://www.linuxsir.org/bbs/showthread.php?t=180376&highlight=windows)
- 下载**grub for dos**，将其中的grldr拷到c:\
- __notepad c:\boot.ini__，添加后面一行，``c:\grldr="grub"``
- 重启，菜单里面选grub，按"c"键，依次打下面的命令(支持tab补全)，X为linux的根分区序号

     grub>root (hd0,X)
     grub>setup (hd0)
     grub>reboot

###  无法进入windows，停在grub>处 
Y是windows下C盘所在分区的序号

     grub>rootnoverify (hd0,Y)
     grub>chainloader +1
     grub>boot


###  无法进入windows，连grub>都看不到 
- 作者是linzi222@linuxsir，原帖在[这里](http://www.linuxsir.org/bbs/archive/index.php/database/t-260082.html)
- 用windows安装盘启动，加载驱动后，按"R"键进入故障修复控制台
- 输入命令``fixboot c:``
- 重启
- 还不行就试试 __fixmbr__


## 其他

### 无法进入X

- 重启，startx；
- dpkg-reconfigure xserver-xorg，startx
- 提示没权限，则dpkg-reconfigure x11-common，startx


### 关于framebuffer

    modconf->kernel->drivers->vedio->vga16fb

### 声卡驱动

{% highlight bash %}
    apt-get install alsa-utils alsa-oss
    alsaconf
{% endhighlight %}

### dig
    ``apt-get install dnsutils``


### apache + mysql + php 
- [apache虚拟主机](http://wiki.ubuntu.org.cn/Apache%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA%E6%8C%87%E5%8D%97)
- [lamp配置](https://wiki.debian.org/zh_CN/LAMP)
- [Debian 6 下 Apache+MySQL+MySQL的LAMP服务器的配置](http://www.duyaofei.com/2012/03/29/vps-%E6%96%B0%E6%89%8B%E6%95%99%E7%A8%8B11%EF%BC%9Adebian-6-%E4%B8%8B-apachemysqlmysql%E7%9A%84lamp%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%85%8D%E7%BD%AE/)

{% highlight bash %}
apt-get install apache2
apt-get install mysql-server
apt-get install libapache2-mod-php5 php5 php-pear php5-xcache php5-curl
apt-get install php5-mysql
apt-get install php5-gd
apt-get install imagemagick php5-imagick
{% endhighlight %}
