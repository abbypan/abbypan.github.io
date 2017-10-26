---
layout: post
category : "freedom"
title:  "访问互联网：ssh 远程登陆配置，ssh tunnel配置"
tagline: "笔记"
tags : [ "great.w", "ssh", "socks5" ]
---
{% include JB/setup %}

* TOC
{:toc}

# 说明

方案：
- 安装ssh/putty，本地提供ssh tunnel。本机浏览器、Dropbox等客户端直接使用tunnel。
- 安装polipo/privoxy，本地提供http proxy，再转发到ssh tunnel。android / ios 下配置wlan连接使用该http proxy。比openvpn速度快很多。

优点：稳定，连接比较快

缺点：配置比较麻烦

建议：android / linux / windows 下使用

# 使用ssh进行远程登录

假设远程机子叫remote，地址为xxx.xxx.xxx.xxx，用户名为someuser

## 输密码

### 每次手动输密码

ssh xxx.xxx.xxx.xxx -l someuser

### 直接命令行传密码

需要预先安装 sshpass

sshpass -p somepasswd ssh someuser@xxx.xxx.xxx.xxx

## 不输密码（公钥认证）

在本地用ssh-keygen -t rsa生成 remote_rsa/remote_rsa.pub的密钥对，要求输passphrase时可以置空，不然登录的时候虽然不用输密码，passphrase又逃不掉了。

把本地生成的remote_rsa.pub传到remote上的/home/someuser/.ssh/目录下，并改名为authorized_keys。

在本地用``ssh -i remote_rsa someuser@xxx.xxx.xxx.xxx``命令进行远程登录。 

### 存入配置文件

也可以写入本地``~/.ssh/config``文件，后续可以用 ssh someuser@remote 直接登陆

注意remote_rsa是私钥

    Host remote
        HostName xxx.xxx.xxx.xxx
        Port 22
        User someuser
        IdentityFile ~/.ssh/remote_rsa


### 批量免登陆

批量指定多台机器免登陆

```
Host *.xxx.com
    IdentityFile ~/.ssh/remote_rsa
    User someuser
```

### 多层ssh

参考：[transparent multi hop](http://sshmenu.sourceforge.net/articles/transparent-mulithop.html)

假设登陆顺序： 本地 -> middle -> remote

假设middle登陆端口为12345，remote登陆端口为23456

在三台机器上安装netcat

``公钥认证``配置，使得：``本地``能够不输密码登陆middle，middle能够不输密码登陆``remote``

本地``.ssh/config``示例

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

middle上的``.ssh/config``示例

    Host remote
    User remuser
    Hostname rem.yyy.com
    Port 23456
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/remote_rsa

## ssh 保持连接

参考 [Keep Your Linux SSH Session From Disconnecting](http://www.howtogeek.com/howto/linux/keep-your-linux-ssh-session-from-disconnecting/)，在``~/.ssh/config``中添加
{% highlight bash %}
Host *
  ServerAliveInterval 60
{% endhighlight %}

# ssh tunnel

## android 

安装 sshtunnel app，配置host相关信息即可

## linux环境

``ssh someuser@remote -N -D 127.0.0.1:8888 -F ~/.ssh/config``

## windows环境

下载 [plink](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)

根据用户名、密码登录： ``plink -C -D 8888 -N someuser@xxx.xxx.xxx.xxx -pw somepasswd``

根据用户名、私钥登录： ``plink -C -D 8888 -N someuser@xxx.xxx.xxx.xxx -i private.ppk``

### 将文本形式的私钥文件 remote_rsa.key 转换成 putty可用的ppk文件

打开 PuTTYgen

选择conversions -> import key，载入 remote_rsa

选择save private key，生成 private.ppk

![puttygen](/assets/posts/puttygen.jpg)

# 浏览器使用ssh tunnel

## 浏览器DNS配置

以firefox为例，about:config设置network.proxy.socks_remote_dns为true


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


# http proxy

## linux 环境

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

## windows 环境

安装 [privoxy](https://www.privoxy.org/)

{% highlight bash %}
# config.txt
listen-address 0.0.0.0:9999
forward-socks5 / 127.0.0.1:8888 .
{% endhighlight %}

# 使用 http proxy

假设本地开启http proxy的机器内网ip为 192.168.1.111。

## PC

``curl -x http://192.168.1.111:9999  https://ipinfo.io``

``curl -x socks5://192.168.1.111:8888  https://ipinfo.io``

## android

无线配置：在wlan ssid名称处长按，选择“高级选项”，填入本地http proxy地址 192.168.1.111 、端口 9999。

指定某些app使用proxy：可安装 [ProxyDroid](https://play.google.com/store/apps/details?id=org.proxydroid)，需要root权限

## ios

ios配置与android类似。

# socks tunnel使用方法（windows简易版）

## 购买vps

假设已购买了vps，ip地址为xxx.xxx.xxx.xxx，用户名为someusr，密码为somepasswd

## ssh tunnel

下载 [plink](http://www.chiark.greenend.org.uk/%7Esgtatham/putty/download.html)

本地新建一个 p.bat 文件，其内容为

    plink -C -D 8888 -N someusr@xxx.xxx.xxx.xxx -pw somepasswd

将p.bat保存在与plink.exe相同目录下。

双击p.bat，运行，遇到提示信息选择 y (yes)，此时本地端口为8888，不要关闭窗口。

## 浏览器

以firefox浏览器为例，下载并安装：[firefox-portable-install](http://portableapps.com/apps/internet/firefox_portable)

打开firefox-portable，option配置如下：

![firefox-socks](/assets/posts/firefox_socks.png)

配置完毕后直接测试访问google。
