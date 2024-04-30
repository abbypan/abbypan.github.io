---
layout: post
category: dns
title:  "Android: bionic dns 分析"
tagline: ""

---
{% include JB/setup %}

* TOC
{:toc}

# 资料

[AOSP DNS 解析器](https://source.android.com/devices/architecture/modular-system/dns-resolver)

[C Programming with the Resolver Library Routines](http://web.deu.edu.tr/doc/oreily/networking/dnsbind/ch14_02.htm)

# res_query.c 

[res_query.c](https://android.googlesource.com/platform/bionic/+/master/libc/dns/resolv/res_query.c)
的 res_nquery 是执行查询的主函数，查询结果为answer。

{% highlight c %}
int
res_nquery(res_state statp,
	   const char *name,	/* domain name */
	   int class, int type,	/* class and type of query */
	   u_char *answer,	/* buffer to put answer */
	   int anslen)		/* size of answer buffer */
{% endhighlight %}

## res_nmkquery

[res_mkquery.c](https://android.googlesource.com/platform/bionic/+/master/libc/dns/resolv/res_mkquery.c)
的 res_nmkquery 负责组查询包。

res_stat的statp里设置一些dns option，例如，是否recurse，是否开启dnssec。

data 在正向query场景下可以置NULL。

buf是最终组装好的查询包

{% highlight c %}
int
res_nmkquery(res_state statp,
	     int op,			/* opcode of query */
	     const char *dname,		/* domain name */
	     int class, int type,	/* class and type of query */
	     const u_char *data,	/* resource record data */
	     int datalen,		/* length of data */
	     const u_char *newrr_in,	/* new rr for modify or append */
	     u_char *buf,		/* buffer to put query */
	     int buflen)		/* size of buffer */
{% endhighlight %}

## res_nsend

[res_send.c](https://android.googlesource.com/platform/bionic/+/master/libc/dns/resolv/res_send.c) 的res_nsend负责将查询包送到目标server的socket，并从server的socket获取应答包。

{% highlight c %}
int
res_nsend(res_state statp,
	  const u_char *buf, int buflen, u_char *ans, int anssiz)  
{% endhighlight %}

res_nsend 从 statp->nsaddr_list[ns] 取server信息。

以UDP查询为例，调用send_dg发送查询包：

{% highlight c %}
n = send_dg(statp, &params, buf, buflen, ans, anssiz, &terrno,
				    ns, &v_circuit, &gotsomewhere, &now, &rcode, &delay);
{% endhighlight %}

send_dg从ns里取socket，发buf查询包，取回应答包ans

params是一些应答参数，例如等待时间

{% highlight c %}
static int
send_dg(res_state statp, struct __res_params* params,
	const u_char *buf, int buflen, u_char *ans, int anssiz,
	int *terrno, int ns, int *v_circuit, int *gotsomewhere,
	time_t *at, int *rcode, int* delay)
...
	s = EXT(statp).nssocks[ns];
...
	if (send(s, (const char*)buf, (size_t)buflen, 0) != buflen) {
...
	if (sendto(s, (const char*)buf, buflen, 0, nsap, nsaplen) != buflen)
...
resplen = recvfrom(s, (char*)ans, (size_t)anssiz,0,
			   (struct sockaddr *)(void *)&from, &fromlen);
{% endhighlight %}


# res_init.c 

[res_init.c](https://android.googlesource.com/platform/bionic/+/master/libc/dns/resolv/res_init.c)

__res_vinit是初始化读取一些系统resolver列表，放到statp里。

如果#ifdef USELOOPBACK为true，会先把loopback的v4, v6地址添加到res_sockaddr_union u数组里，再调res_setservers放到statp里。

然后是读取环境变量，resolv.conf之类的操作，同样添到statp里。

{% highlight c %}
int
__res_vinit(res_state statp, int preinit)

...

res_setservers(statp, u, nserv);
{% endhighlight %}

# getaddrinfo.c 

[getaddrinfo.c](https://android.googlesource.com/platform/bionic/+/master/libc/dns/net/getaddrinfo.c)

querybuf的hdr即为包头，buf即为dns包内容，注意hdr与buf的起始地址相同，内存是共用的。

{% highlight c %}
typedef union {
	HEADER hdr;
	u_char buf[MAXPACKET];
} querybuf;

static struct addrinfo *
getanswer(const querybuf *answer, int anslen, const char *qname, int qtype, const struct addrinfo *pai)
{% endhighlight %}
