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

https://github.com/abbypan/dnsmasq_dnscrypt_configure

主要防劫持，如google.com/dropbox.com之类。小部分提升隐私，减少dns leak。

参考：

[dnsmasq](https://wiki.archlinux.org/index.php/dnsmasq)

[DNSCrypt](https://dnscrypt.org/)

[dnscrypt-resolvers](https://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-resolvers.csv)

[dnscrypt-wrapper](https://github.com/cofyc/dnscrypt-wrapper)

# plan_a：不搭建自有的解析服务器

说明：国内网站用114解析，国外网站用opendns的dnscrypt加密，不过opendns会发送client subnet且忽略下游client subnet，存在隐私泄漏问题。

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

指定本地监听地址 127.0.0.1:53330

指定remote_dnscrypt_pub_resolver信息

运行

{% highlight bash %}
$ sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
{% endhighlight %}

# plan_b：自建支持dnscrypt解析服务器

说明：国内网站用114解析，国外网站dnscrypt加密，通过自建的forwarding转发及resolver实现简单防dns污染及解析信息隐藏。

本地安装 dnsmasq，dnscrypt-proxy

/etc/resolver.conf 中指定nameserver为127.0.0.1，即使用本地dnsmasq提供53服务

DNS隐私的一个大问题是多数到权威的查询是明文，可以用一层跳板稍微增加溯源时关联分析的成本。这里不考虑经过的线路运营商流量数据共享分析，用TOR匿名查询，或者混杂查询等情况。

注意，为保证解析到最合适的IP，local_open_resolver(xxx.xxx.xxx.xxx)的后端resolver_ip要与本地IP线路geolocation相近，自建的remote_dnscrypt_resolver(zzz.zzz.zzz.zzz)要与负责访问www.google.com的代理IP线路geolocation相近。

{% highlight bash %}
weibo.cn 
<--plain--> dnsmaq(127.0.0.1:53) 
<--plain--> local_open_resolver(xxx.xxx.xxx.xxx)

www.google.com 
<--plain--> dnsmaq(127.0.0.1:53) 
<--plain--> localhost_dnscrypt_forwarding(127.0.0.1:53330, dnscrypt-proxy) 
<--dnscrypt--> remote_dnscrypt_forwarding(yyy.yyy.yyy.yyy:53332, dnscrypt-wrapper) 
<--plain--> remote_dnscrypt_forwarding(yyy.yyy.yyy.yyy, 127.0.0.1:53333, dnscrypt-proxy) 
<--dnscrypt--> remote_dnscrypt_resolver(zzz.zzz.zzz.zzz:53335, dnscrypt-wrapper) 
<--plain--> remote_dnscrypt_resolver(zzz.zzz.zzz.zzz, 127.0.0.1:53, bind)
{% endhighlight %}

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

yyy.yyy.yyy.yyy 的 dnscrypt-proxy 配置的是 zzz.zzz.zzz.zzz 的信息

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

本地的 dnscrypt-proxy 配置的是 yyy.yyy.yyy.yyy 的信息

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

# plan_c：自建支持dnscrypt解析服务器，但是不使用forwarding做中间隐藏

说明：国内网站用114解析，国外网站dnscrypt加密，通过自建的resolver简单搭建防dns污染的服务器，信息隐藏程度低。

本地安装 dnsmasq，dnscrypt-proxy

/etc/resolver.conf 中指定nameserver为127.0.0.1，即使用本地dnsmasq提供53服务

remote_dnscrypt_resolver(xxx.xxx.xxx.xxx) 负责接收dnscrypt-proxy查询，转换成传统明文查询发到真正负责解析的resolver

负责解析的resolver可以是自建的bind，或者直接采用google public dns之类

本地配置参考plan_a，dnswrapper + resolver 配置参考plan_b


    weibo.cn
    <--plain--> dnsmaq(127.0.0.1:53)
    <--plain--> local_open_resolver(202.106.46.151)

    www.google.com
    <--plain--> dnsmaq(127.0.0.1:53)
    <--plain--> localhost_dnscrypt_forwarding(127.0.0.1:53330, dnscrypt-proxy)
    <--dnscrypt--> remote_dnscrypt_resolver(xxx.xxx.xxx.xxx:53332, dnscrypt-wrapper)
    <--plain--> remote_dnscrypt_resolver(xxx.xxx.xxx.xxx, 127.0.0.1:53, bind)
                or  
                remote_dnscrypt_resolver(xxx.xxx.xxx.xxx, 8.8.8.8, google dns)
