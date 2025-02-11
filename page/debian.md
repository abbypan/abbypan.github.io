---
layout: page
title: "debian"
---
{% include JB/setup %}

* toc
{:toc}

# 安装

##  设置apt源 
- BIOS里选网络启动，重启，选debian网络安装； 
- 网络启动介绍见[PXE.USTC 基本文档](http://pxe.ustc.edu.cn)
- 也可以参考[硬盘安装说明 by lixuebai@ustc](http://mail.ustc.edu.cn/~lixuebai/GNU/DebianInstall.html)
- 手动输入源：``debian.ustc.edu.cn``；
- /etc/apt/source.list
   - ftp://debian.ustc.edu.cn/sources.list/
   - ``deb ftp://202.38.73.198/debian sid foo``


##  /etc/environment 

    LANG="zh_CN.UTF-8"
    LANGUAGE="zh_CN:zh"

##  /etc/fstab 

``/dev/sda1 /mnt/usb vfat user,rw,noauto,utf8=1,fmask=113,dmask=022,umask=022 0 0``

## locale

``sudo apt-get install locales``

编辑 ``/etc/locale.gen`` ，例如 ``en_US.UTF-8``

``locale-gen``

在 ``~/.bashrc`` 中 ``export LC_ALL=en_US.UTF-8``

##  基础包 

{% highlight bash %}
sudo apt-get install build-essential dnsutils cpanminus sendemail
sudo apt-get install libwww-perl libclass-methodmaker-perl libb-utils-perl libpadwalker-perl libcrypt-ssleay-perl libxml-parser-perl libdata-dump-streamer-perl libtemplate-perl libjson-perl libarchive-zip-perl perltidy libdist-zilla-perl
sudo cpanm Plack Plack::Handler::Apache2
sudo apt-get install phantomjs lftp
{% endhighlight %}


# 网络

##  adsl 

- 主要参考这两个贴子：[adsl by Fly1945@Hiweed](http://linux.hiweed.com/node/2467)，[adsl配置 by ryang](http://ryang.68ab.com/debian.html#sec8)
- ``sudo apt-get install pppoe``
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



##  vpn 
- 主要参考这几个贴子
  - [VPN连接校园网 by kkk@ustc](http://bbs.ustc.edu.cn/cgi/bbscon?bn=Linux&fn=M3F936B98&num=2136)
  - [pptp-linux拨vpn by hacker ustc](http://bbs.ustc.edu.cn/cgi/bbscon?bn=Linux&fn=M454D58AB&num=2351)
  - [PPTP CLient by James Cameron](http://pptpclient.sourceforge.net/howto-debian.phtml)
  - [发一个让校内ip走vpn路由的perl脚本吧](http://bbs.ustc.edu.cn/cgi/bbstcon?board=Script&file=M.1211129882.A)
- ``sudo apt-get install pptp-linux``
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

## 无线
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
   - sudo apt-get install wpasupplicant wireless-tools
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


# 其他

## firewall

    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp

## 无法进入X

- 重启，startx；
- dpkg-reconfigure xserver-xorg，startx
- 提示没权限，则dpkg-reconfigure x11-common，startx


## 声卡驱动

{% highlight bash %}
    sudo apt-get install alsa-utils alsa-oss
    alsaconf
{% endhighlight %}

## apache + mysql + php 
- [apache虚拟主机](http://wiki.ubuntu.org.cn/Apache%E8%99%9A%E6%8B%9F%E4%B8%BB%E6%9C%BA%E6%8C%87%E5%8D%97)
- [lamp配置](https://wiki.debian.org/zh_CN/LAMP)
- [Debian 6 下 Apache+MySQL+MySQL的LAMP服务器的配置](http://www.duyaofei.com/2012/03/29/vps-%E6%96%B0%E6%89%8B%E6%95%99%E7%A8%8B11%EF%BC%9Adebian-6-%E4%B8%8B-apachemysqlmysql%E7%9A%84lamp%E6%9C%8D%E5%8A%A1%E5%99%A8%E7%9A%84%E9%85%8D%E7%BD%AE/)

{% highlight bash %}
sudo apt-get install apache2 libapache2-mod-perl2
sudo apt-get install libapache2-mod-php php php-pear php-curl
sudo apt-get install bsdutils mariadb-server php-mysql
sudo apt-get install imagemagick php-imagick php-gd
{% endhighlight %}

修改配置后重启apache2：``sudo apache2ctl graceful``

## 反向代理

假设用户访问 https://rev.pxy.com 相当于访问 https://www.target.com

在rev.pxy.com上配置模块

     a2enmod proxy
     a2enmod proxy_http
     a2enmod rewrite
     a2enmod headers
     a2enmod proxy_connect
     a2enmod proxy_html


在rev.pxy.com上配置`/etc/apache2/site-enable/xxx.conf`:

    <VirtualHost *:443>
    SSLEngine On
    ServerName rev.pxy.com
    SSLProxyEngine On
    ProxyPass / https://www.target.com/
    ProxyPassReverse / https://www.target.com/
    SSLCertificateFile /home/someusr/.cert/fullchain.pem
    SSLCertificateKeyFile /home/someusr/.cert/privkey.pem
    </VirtualHost>



## deiban 系统降级内核

[Downgrade from Debian SID to Stable from Jessie to Wheezy](http://ispire.me/downgrade-from-debian-sid-to-stable-from-jessie-to-wheezy/)
