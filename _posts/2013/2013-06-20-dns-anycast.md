---
layout: post
category: dns
title:  "DNS Root & Anycast"
tagline: ""
tags : [ "dns", "root", "anycast" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Root

全球根服务：http://www.iana.org/domains/root/servers

全球根镜像：http://www.root-servers.org/map/

## 快速

根区访问的时延抖动一般不会对用户终端体验产生明显的影响，原因在于DNS分层解析的架构，递归上热点域名的时延变化影响更加直接一点

anycast的时延优化效果评估：rtt状态，跨网访问，本地vs异地

其次是部署geo及isp选择策略的问题，保证重点地区的镜像覆盖

## 稳定

bgp路由劫持，不用说了。。。

bgp路由泄漏，如果是大型isp，可能导致某些区域的根流量被重定向到非最优的路径

根服务器IP切换问题，又涉及recursive端hint文件的更新，应急缓存优化等等

根NS的DNSSEC校验链太长的问题，.net下来回切换

13个NS RRSIG太长，未来是否统一成单个root label也ICANN RSSAC组讨论选项中

## 安全

DNSSEC

RFC7706, Run Root on Loopback

本地是否有可信的根镜像服务

根服务器自身的安全性

## 管理

顶级域在根区生存权管理的问题，谁负责更新根区文件的问题，ICANN移交管理权

极端场景下，保持与世界互联互通的问题

以DNSSEC为基础，多区域共治，本地anycast优化，递归hint file/root zonefile load定期更新等等

根区密钥轮转，根镜像载入zonefile前后时延

# anycast 资料
 
[anycast介绍](http://www.net.cmu.edu/pres/anycast/)

[dns anycast实作](http://netlinxinc.com/netlinx-blog/45-dns.html?layout=default)

[anycast 对比 unicast 的好处](http://communitydns.eu/Anycast.pdf)

[cisco Challenges to DNS Scaling](http://www.cisco.com/web/about/ac123/ac147/archived_issues/ipj_14-4/144_dns.html)

[icann 2009.08.Scaling the Root Report on the Impact on the DNS Root System of Increasing the Size and Volatility of the Root Zone](https://www.icann.org/en/system/files/files/root-scaling-study-report-31aug09-en.pdf)

[icann 2009.09.Root Scaling Study Description of the DNS Root Scaling Model](https://www.icann.org/en/system/files/files/root-scaling-model-description-29sep09-en.pdf)

[icann 2010.10 Summary of the Impact of Root Zone Scaling](https://www.icann.org/en/topics/new-gtlds/summary-of-impact-root-zone-scaling-06oct10-en.pdf)


## F根
看当前访问的F根的镜像
{% highlight bash %}
dig hostname.bind @f.root-servers.net chaos txt
traceroute @f.root-servers.net
{% endhighlight %}

## K根
看当前访问的K根的镜像
{% highlight bash %}
dig id.server @k.root-servers.net chaos txt
traceroute @k.root-servers.net
{% endhighlight %}

## L根
参考[draft-jabley-dnsop-anycast-mapping-04](http://tools.ietf.org/html/draft-jabley-dnsop-anycast-mapping-04)

看L根的镜像列表
{% highlight bash %}
dig NODES.L.ROOT-SERVERS.ORG TXT +short +tcp
{% endhighlight %}

看当前访问的L根的镜像 
{% highlight bash %}
dig -4 @L.ROOT-SERVERS.NET ID.SERVER CH TXT +short
dig -6 @L.ROOT-SERVERS.NET ID.SERVER CH TXT +short
dig IDENTITY.L.ROOT-SERVERS.ORG TXT +short 
dig IDENTITY.L.ROOT-SERVERS.ORG A +short
{% endhighlight %}

## TLD: ORG
看当前访问的.ORG TLD镜像：
{% highlight bash %}
dig whoareyou.ultradns.net @tld1.ultradns.net
dig whoareyou.ultradns.net @tld2.ultradns.net 
{% endhighlight %}
