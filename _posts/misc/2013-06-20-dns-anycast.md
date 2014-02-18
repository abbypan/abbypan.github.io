---
layout: post
category : tech
title:  "DNS Anycast 资料"
tagline: ""
tags : ["dns", "anycast"] 
---
{% include JB/setup %}
 
见：
- [anycast介绍](http://www.net.cmu.edu/pres/anycast/)
- [dns anycast实作](http://netlinxinc.com/netlinx-blog/45-dns.html?layout=default)
- [anycast 对比 unicast 的好处](http://communitydns.eu/Anycast.pdf)

## 根镜像

全球根服务：http://www.iana.org/domains/root/servers

全球根镜像：http://www.root-servers.org/map/

### F根
看当前访问的F根的镜像
{% highlight bash %}
dig hostname.bind @f.root-servers.net chaos txt
traceroute @f.root-servers.net
{% endhighlight %}

### K根
看当前访问的K根的镜像
{% highlight bash %}
dig id.server @k.root-servers.net chaos txt
traceroute @k.root-servers.net
{% endhighlight %}

### L根
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

## TLD 镜像

### ORG
看当前访问的.ORG TLD镜像：
{% highlight bash %}
dig whoareyou.ultradns.net @tld1.ultradns.net
dig whoareyou.ultradns.net @tld2.ultradns.net 
{% endhighlight %}
