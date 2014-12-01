---
layout: post
category : 穿越火线
title:  "Linux Hotcloning 系统备份，双机热备"
tagline: ""
tags : [ "linux", "hotcloning" ] 
---
{% include JB/setup %}

主要参考：[Hotcloning: cloning a running server](http://olivier.sessink.nl/publications/hotcloning/)

下面以debian系统的vps热备为例（不仅限于debian）

假设主机器为 main.xxx.com，ip为xxx.xxx.xxx.xxx

备份机器为 bak.yyy.com，ip为yyy.yyy.yyy.yyy

# 在main上配置免密码自动热备

参考ssh的公钥访问介绍，生成公私钥对：``~/.ssh/authorized_keys``、``~/.ssh/id_rsa``

在main上``~/.ssh/config``中添加main.xxx.com的公钥登录配置，例如

    Host m
    User root
    Hostname main.xxx.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/id_rsa

假设新建一个``/root/backup``文件夹，在该目录下

新建一个``hotclone_exclude.txt``文件，内容例如

    /boot/
    /lib/modules
    /etc/modules
    /etc/lilo.conf
    /etc/fstab
    /etc/mtab
    /proc
    /dev
    lost+found/
    /var/log
    /etc/network/
    /root/.ssh/known_hosts

新建一个``hotclone.crontab``文件，内容例如
{% highlight bash %}
0 */6 * * * cd /root/backup && ./hotclone.sh >/dev/null 2>&1
{% endhighlight %}

新建一个``hotclone.sh``文件，内容例如
{% highlight bash %}
#!/bin/bash
f=`ifconfig | grep 'xxx.xxx.xxx.xxx'`
if [[ -n $f ]]; then
    echo "backup"
else
    echo "hotclone"
    /usr/bin/rsync -e ssh -avz --exclude-from=/root/backup/hotclone_exclude.txt --delete root@idouzi.tk:/ /
    /usr/bin/crontab /root/backup/hotclone.crontab
fi
{% endhighlight %}

# 在bak上手动备份

- 安装debian minimal版本
- 安装rsync：``apt-get install rsync``
- 新建一个hotclone_exclude.txt，内容与上面的相同
- 执行备份：``rsync -e ssh -avz --exclude-from=hotclone_exclude.txt --delete root@main.xxx.com:/ /``
- 重启：``reboot``

# 检查 

- 手动再执行一次备份，检查是否异常：``rsync -e ssh -avz --exclude-from=hotclone_exclude.txt --delete root@main.xxx.com:/ /``
- 检查是否每隔6小时自动热备
