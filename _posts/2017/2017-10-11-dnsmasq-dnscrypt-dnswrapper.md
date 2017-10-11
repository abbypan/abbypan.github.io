---
layout: post
category: tech
title:  "搭建 dnsmasq + dnscrypt 解析组合"
tagline: ""
tags: [ "dns", "hijack", "privacy", "dnsmasq", "dnswrapper", "dnscrypt" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 说明

主要防劫持，如google.com/dropbox.com之类。小部分提升隐私，减少dns leak。

参考：

[dnsmasq](https://wiki.archlinux.org/index.php/dnsmasq)

[DNSCrypt](https://dnscrypt.org/)

[dnscrypt-resolvers](https://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-resolvers.csv)

[dnscrypt-wrapper](https://github.com/cofyc/dnscrypt-wrapper)

# 方案1：不搭建自有的解析服务器

本地安装 dnsmasq，dnscrypt-proxy

/etc/resolver.conf 中指定nameserver为127.0.0.1，即使用本地dnsmasq提供53服务

{% highlight bash %}
weibo.cn 
<--plain--> dnsmaq(127.0.0.1:53) 
<--plain--> local_pub_resolver(114.114.114.114)

www.google.com 
<--plain--> dnsmaq(127.0.0.1:53) 
<--plain--> localhost_dnscrypt_forwarding(127.0.0.1:53330, dnscrypt-proxy) 
<--dnscrypt--> remote_dnscrypt_pub_resolver(208.67.220.220, opendns)
{% endhighlight %}

## dnsmasq

/etc/dnsmasq.conf 指定本地监听端口为53，默认解析服务器为 local_pub_resolver

{% highlight bash %}
port=53
no-resolv
no-poll
conf-dir=/etc/dnsmasq.d
server=114.114.114.114
{% endhighlight %}

/etc/dnsmasq.d/local.conf 指定将cn之类的本地域名转发到local_pub_resolver查询，详细列表可参考[dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list)

{% highlight bash %}
server=/cn/114.114.114.114
server=/qq.com/114.114.114.114
{% endhighlight %}

/etc/dnsmasq.d/remote.conf 指定将google.com之类的域名转发到localhost_dnscrypt_forwarding的127.0.0.1:53330

{% highlight bash %}
server=/google.com/127.0.0.1#53330
{% endhighlight %}

运行

{% highlight bash %}
$ sudo dnsmasq
{% endhighlight %}

## dnscrypt-proxy

/etc/dnscrypt-proxy.conf

指定本地监听地址 127.0.0.1:53330

指定remote_dnscrypt_pub_resolver信息

{% highlight bash %}
#/etc/dnscrypt-proxy.conf
LocalAddress 127.0.0.1:53330

ProviderName 2.dnscrypt-cert.opendns.com
ProviderKey B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79
ResolverAddress 208.67.220.220

Daemonize yes
{% endhighlight %}

运行

{% highlight bash %}
$ sudo dnscrypt-proxy /etc/dnscrypt-proxy.conf
{% endhighlight %}

# 方案2：自建支持dnscrypt解析服务器

本地安装 dnsmasq，dnscrypt-proxy

/etc/resolver.conf 中指定nameserver为127.0.0.1，即使用本地dnsmasq提供53服务

{% highlight bash %}
weibo.cn 
<--plain--> dnsmaq(127.0.0.x:53) 
<--plain--> local_open_resolver(xxx.xxx.xxx.xxx)

www.google.com 
<--plain--> dnsmaq(127.0.0.1:53) 
<--plain--> localhost_dnscrypt_forwarding(127.0.0.1:53330, dnscrypt-proxy) 
<--dnscrypt--> remote_dnscrypt_forwarding(yyy.yyy.yyy.yyy:53332, dnscrypt-wrapper) 
<--plain--> remote_dnscrypt_forwarding(yyy.yyy.yyy.yyy, 127.0.0.1:53333, dnscrypt-proxy) 
<--dnscrypt--> remote_dnscrypt_resolver(zzz.zzz.zzz.zzz:53335, dnscrypt-wrapper) 
<--plain--> remote_bind(zzz.zzz.zzz.zzz, 127.0.0.1:53, bind)
{% endhighlight %}

DNS隐私的一个大问题是多数到权威的查询是明文，可以用一层跳板稍微增加溯源时关联分析的成本。这里不考虑经过的线路运营商流量数据共享分析，用TOR匿名查询，或者混杂查询等情况。

注意，为保证解析到最合适的IP，local_open_resolver(xxx.xxx.xxx.xxx)的后端resolver_ip要与本地IP线路geolocation相近，自建的remote_dnscrypt_resolver(zzz.zzz.zzz.zzz)要与负责访问www.google.com的代理IP线路geolocation相近。

## remote_dnscrypt_resolver : zzz.zzz.zzz.zzz

在zzz.zzz.zzz.zzz上搭建bind， /etc/bind/named.conf.options 配置只允许接收本地查询

{% highlight bash %}
options {
    ...

    recursion yes;
    allow-recursion { 127.0.0.1; };
};
{% endhighlight %}

参考 [dnscrypt-wrapper](https://github.com/cofyc/dnscrypt-wrapper) 的安装说明，在zzz.zzz.zzz.zzz搭建dnscrypt服务端

配置开放dnscrypt监听端口为53335，providername的域名为 mytestresolver.com，最终解析使用bind服务

{% highlight bash %}
$ sudo mkdir /etc/dnscrypt-wrapper
$ cd /etc/dnscrypt-wrapper
$ sudo dnscrypt-wrapper --gen-provider-keypair | tee zzz.public.key.info
$ sudo dnscrypt-wrapper --gen-crypt-keypair --crypt-secretkey-file=1.key
$ sudo dnscrypt-wrapper --gen-cert-file --crypt-secretkey-file=1.key --provider-cert-file=1.cert \
                   --provider-publickey-file=public.key --provider-secretkey-file=secret.key
$ sudo dnscrypt-wrapper --resolver-address=127.0.0.1:53 --listen-address=0.0.0.0:53335 \
                   --provider-name=2.dnscrypt-cert.mytestresolver.com \
                   --crypt-secretkey-file=1.key --provider-cert-file=1.cert
{% endhighlight %}


## remote_dnscrypt_forwarding: yyy.yyy.yyy.yyy

yyy.yyy.yyy.yyy 的 /etc/dnscrypt-proxy.conf 配置的是 zzz.zzz.zzz.zzz 的信息, ProviderKey 从 zzz.public.key.info 提取

{% highlight bash %}
LocalAddress 127.0.0.1:53333

ProviderName 2.dnscrypt-cert.mytestresolver.com
ProviderKey XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
ResolverAddress zzz.zzz.zzz.zzz:53335

Daemonize yes
{% endhighlight %}

yyy.yyy.yyy.yyy 的 /etc/dnscrypt-wrapper 配置的是在53332监听客户端dnscrypt查询，转成plain查询后，提交给本地的dnscrypt-proxy 53333

{% highlight bash %}
$ sudo mkdir /etc/dnscrypt-wrapper
$ cd /etc/dnscrypt-wrapper
$ sudo dnscrypt-wrapper --gen-provider-keypair | tee yyy.public.key.info
$ sudo dnscrypt-wrapper --gen-crypt-keypair --crypt-secretkey-file=1.key
$ sudo dnscrypt-wrapper --gen-cert-file --crypt-secretkey-file=1.key --provider-cert-file=1.cert \
                   --provider-publickey-file=public.key --provider-secretkey-file=secret.key
$ sudo dnscrypt-wrapper --resolver-address=127.0.0.1:53333 --listen-address=0.0.0.0:53332 \
                   --provider-name=2.dnscrypt-cert.mytestforwarding.com \
                   --crypt-secretkey-file=1.key --provider-cert-file=1.cert
{% endhighlight %}

## 本地dnscrypt-proxy

本地的 /etc/dnscrypt-proxy.conf 配置的是 yyy.yyy.yyy.yyy 的信息, ProviderKey 从 yyy.public.key.info 提取

{% highlight bash %}
#/etc/dnscrypt-proxy.conf
LocalAddress 127.0.0.1:53330

ProviderName 2.dnscrypt-cert.mytestforwarding.com
ProviderKey XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX:XXXX
ResolverAddress yyy.yyy.yyy.yyy:53332

Daemonize yes
{% endhighlight %}

## 本地dnsmasq

/etc/dnsmasq.conf 指定本地监听端口为53，默认解析服务器为 local_open_resolver

{% highlight bash %}
port=53
no-resolv
no-poll
conf-dir=/etc/dnsmasq.d
server=xxx.xxx.xxx.xxx
{% endhighlight %}

/etc/dnsmasq.d/local.conf 

{% highlight bash %}
server=/cn/xxx.xxx.xxx.xxx
server=/qq.com/xxx.xxx.xxx.xxx
{% endhighlight %}

/etc/dnsmasq.d/remote.conf

{% highlight bash %}
server=/google.com/127.0.0.1#53330
{% endhighlight %}
