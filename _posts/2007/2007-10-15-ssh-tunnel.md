---
layout: post
category : "tech"
title:  "ssh tunnel"
tagline: "socks5 + http proxy"
tags : [ "proxy", "ssh" ]
---
{% include JB/setup %}

* TOC
{:toc}

# 说明

安装ssh/plink/putty，本地提供socks tunnel。本机浏览器、Dropbox等客户端直接使用socks tunnel。

安装polipo/privoxy，本地提供http proxy，再转发到socks tunnel。android / ios 手机配置wlan连接使用该http proxy。

假设远程vps为remote，ip地址为xxx.xxx.xxx.xxx，用户名为someusr，密码为somepasswd

# windows 

## socks

下载 [plink](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

根据用户名、密码登录： ``plink -C -D 8888 -N someusr@xxx.xxx.xxx.xxx -pw somepasswd``

根据用户名、私钥登录： ``plink -C -D 8888 -N someusr@xxx.xxx.xxx.xxx -i private.ppk``

或者本地新建一个 p.bat 文件，其内容为

    plink -C -D 8888 -N someusr@xxx.xxx.xxx.xxx -pw somepasswd

将p.bat保存在与plink.exe相同目录下。

双击p.bat，运行，遇到提示信息选择 y (yes)，此时本地端口为8888，不要关闭窗口。


## http proxy

安装 [privoxy](https://www.privoxy.org/)

{% highlight bash %}
# config.txt
listen-address 0.0.0.0:9999
forward-socks5 / 127.0.0.1:8888 .
{% endhighlight %}

## 将文本形式的私钥文件 remote_rsa.key 转换成 putty可用的ppk文件

打开 PuTTYgen

选择conversions -> import key，载入 remote_rsa

选择save private key，生成 private.ppk

![puttygen](/assets/posts/puttygen.jpg)


# linux

## socks

``ssh someusr@remote -N -D 127.0.0.1:8888 -F ~/.ssh/config``

## http proxy

安装 polipo

[通过 Socks5 Proxy 实现 HTTP Proxy](http://cs-cjl.com/2014/10/29/http_proxy)

[archlinux polipo](https://wiki.archlinux.org/index.php/Polipo_%28%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87%29)

{% highlight bash %}
# /etc/polipo/config
proxyAddress = "0.0.0.0"
proxyPort = 9999
socksParentProxy = "127.0.0.1:8888"
socksProxyType = socks5
{% endhighlight %}

直接执行``sudo polipo``即可成功开启本地http proxy

# android

安装 sshtunnel app，配置host相关信息

假设本地开启http proxy的机器内网ip为 192.168.1.111

android 无线配置：在wlan ssid名称处长按，选择“高级选项”，填入本地http proxy地址 192.168.1.111 、端口 9999。

android 指定某些app使用proxy：可安装 [ProxyDroid](https://play.google.com/store/apps/details?id=org.proxydroid)，需要root权限

ios配置与android类似。

# curl

假设本地开启proxy的机器内网ip为 192.168.1.111

``curl -x http://192.168.1.111:9999  https://ipinfo.io``

``curl -x socks5://192.168.1.111:8888  https://ipinfo.io``

# 浏览器

以firefox为例。

打开firefox，下载并安装扩展 [foxyproxy](https://addons.mozilla.org/zh-CN/firefox/addon/foxyproxy-standard/)

foxyproxy配置如下：

![firefox-socks](/assets/posts/firefox_socks.png)

![firefox-socks](/assets/posts/firefox_socks2.png)

配置完毕后直接测试访问google。

## 浏览器pac文件示例（黑名单），默认直连

{% highlight bash %}
var direct = 'DIRECT';
var http_proxy = 'SOCKS5 127.0.0.1:8888; DIRECT';

var tunnel_list = [
"gmail.com",
"google.com",
"google.com.hk",
"googleapis.com"
];

function FindProxyForURL(url, host) {
    if(! host) return direct;
    for (var i = 0; i < tunnel_list.length; i += 1) {
        var v = tunnel_list[i];
        if ( dnsDomainIs(host, v)) {
            return http_proxy;
        }
    }
    return direct;
};
{% endhighlight %}

## 浏览器pac文件示例（黑白名单），默认代理

{% highlight bash %}
var direct = 'DIRECT';
var http_proxy = 'SOCKS5 127.0.0.1:8888; DIRECT';
var white_list = [
".cn", 
".com.cn",
".qq.com",
".jd.com",
".360buyimg.com",
".baidu.com",
".bdstatic.com",
".douban.com",
"weibo.com",
".taobao.com",
".alipay.com",
".alicdn.com", 
".taobaocdn.com"
];

var black_list = [
"google.com", 
"youtube.com"
];

function FindProxyForURL(url, host) {
    if(! host) return direct;

    for (var i = 0; i < black_list.length; i += 1) {
        var v = black_list[i];
        var dotv = '.' + v;
        if ( dnsDomainIs(host, dotv) || dnsDomainIs(host, v)) {
            return http_proxy;
        }
    }

    for (var i = 0; i < white_list.length; i += 1) {
        var v = white_list[i];
        var dotv = '.' + v;
        if ( dnsDomainIs(host, dotv) || dnsDomainIs(host, v)) {
            return direct;
        }
    }

    return http_proxy;
};
{% endhighlight %}

# 使用ssh进行远程登录

## 每次手动输密码

ssh xxx.xxx.xxx.xxx -l someusr

## 直接命令行传密码

需要预先安装 sshpass

sshpass -p somepasswd ssh someusr@xxx.xxx.xxx.xxx

## 不输密码（公钥认证）

本地用ssh-keygen -t rsa生成 remote_rsa/remote_rsa.pub的密钥对，要求输passphrase时可以置空。

把本地生成的remote_rsa.pub传到remote上的/home/someusr/.ssh/目录下，并改名为authorized_keys。

本地使用``ssh -i remote_rsa someusr@xxx.xxx.xxx.xxx``命令进行远程登录。

本地``~/.ssh/config``配置私钥，后续可以用 ssh someusr@remote 直接登陆

注意remote_rsa是私钥

        Host remote
        HostName xxx.xxx.xxx.xxx
        Port 22
        User someusr
        IdentityFile ~/.ssh/remote_rsa


## 批量免登陆

批量指定多台机器免登陆

```
Host *.xxx.com
IdentityFile ~/.ssh/remote_rsa
User someusr
```

## 多层ssh

参考：[transparent multi hop](http://sshmenu.sourceforge.net/articles/transparent-mulithop.html)

假设登陆顺序： 本地 -> middle -> remote

假设middle登陆端口为12345，remote登陆端口为23456

在三台机器上安装netcat

本地配置 ~/.ssh/config，使得本地能够不输密码，通过middle登陆remote

    Host middle
    User miduser
    Hostname mid.xxx.com
    Port 12345
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/middle_rsa

    Host remote
    Hostname rem.yyy.com
    User remuser
    ProxyCommand ssh -q middle nc -q0 %h 23456
    IdentityFile ~/.ssh/remote_rsa

middle的 ~/.ssh/authorized_keys 为 ~/.ssh/middle_rsa 所对应的公钥

remote的 ~/.ssh/authorized_keys 为 ~/.ssh/remote_rsa 所对应的公钥

rsync使用不受影响： rsync -avzu root@remote:/root/test/ /root/test

ansible需要配置 /etc/ansible/hosts，例如

    [multihop]
    rem.yyy.com

    [multihop:vars]
    ansible_ssh_common_args = -o ForwardAgent=yes -o ControlMaster=auto -o ControlPersist=300s -o ServerAliveInterval=60 -o ProxyCommand="ssh -q middle.xxx.com nc -q0 %h 23456"

## ssh 保持连接

参考 [Keep Your Linux SSH Session From Disconnecting](http://www.howtogeek.com/howto/linux/keep-your-linux-ssh-session-from-disconnecting/)，在``~/.ssh/config``中添加
{% highlight bash %}
Host *
  ServerAliveInterval 60
{% endhighlight %}

## rsync 同步目录

    rsync --progress -avzu --delete remote_usr@remote.xxx.com:/var/remote/ /var/local

    sshpass -p "remote_passwd" rsync --progress -avzu --delete -e ssh remote_usr@remote.xxx.com:/var/remote/ /var/local

