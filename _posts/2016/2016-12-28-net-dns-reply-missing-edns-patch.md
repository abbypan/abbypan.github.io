---
layout: post
category: tech
title:  "Perl Net::DNS 1.06 响应包不带EDNS OPT的问题处理"
tagline: ""
tags: [ "perl", "dns" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# 问题

用 Net::DNS 测试 nameserver，客户端发 EDNS 查询，服务端的响应包一直不带 EDNS OPT。

rt上的bug单 [#115558: Net::DNS::Nameserver does not allow EDNS replies](https://rt.cpan.org/Ticket/Display.html?id=115558&results=b726149ec96a4ba3ede1c65761e1a229)

# 补丁

{% highlight bash %}
--- Net-DNS-1.06_05/lib/Net/DNS/Packet.pm	2016-11-12 11:23:47.000000000 +0800
+++ Net-DNS-1.06_05.fix/lib/Net/DNS/Packet.pm	2016-12-28 16:13:02.577195268 +0800
@@ -237,10 +237,12 @@
 =cut
 
 sub edns {
-	my $self = shift;
-	my $link = \$self->{xedns};
-	($$link) = grep $_->isa(qw(Net::DNS::RR::OPT)), @{$self->{additional}} unless $$link;
-	$$link = new Net::DNS::RR( type => 'OPT' ) unless $$link;
+    my $self = shift;
+    my $link ;
+    $link = \$self->{xedns} if(exists $self->{xedns});
+    ($$link) = grep $_->isa(qw(Net::DNS::RR::OPT)), @{$self->{additional}} unless ($link and $$link);
+    $$link = new Net::DNS::RR( type => 'OPT' ) unless ($link and $$link);
+    return $$link;
 }
{% endhighlight %}

# bug分析

## Nameserver.pm

服务端 tcp_connection / udp_connection  函数先调用 make_reply 生成应答包，再调用 $reply->data 发送给客户端服务端

{% highlight perl %}
    my $reply = $self->make_reply( $query, $sock->peerhost, $conn );

    $reply->data
{% endhighlight %}

## $self->make_reply 制作应答包

$query->reply() 初始化应答包

{% highlight perl %}
    sub make_reply() 

          my $reply = $query->reply();
{% endhighlight %}

### Packet.pm  : sub reply()  如果收到的是edns查询，则初始化应答包时预设edns size

{% highlight perl %}
     $reply->edns->size($UDPmax) if $query->edns->_specified;
{% endhighlight %}


### Packet.pm : sub edns() 取出edns opt对象，bug发生地

{% highlight perl %}
sub edns {
     my $self = shift;
     my $link = \$self->{xedns};
     ($$link) = grep $_->isa(qw(Net::DNS::RR::OPT)), @{$self->{additional}} unless $$link;
     $$link = new Net::DNS::RR( type => 'OPT' ) unless $$link;
}
{% endhighlight %}

如果收到带edns的查询，make_reply初始化时，依次调用

{% highlight perl %}
my $reply = $query->reply();  

$reply->edns->size($UDPmax),
{% endhighlight %}

由于 $self->{xedns} 为空，$link指向 $self->{xedns}　的地址

且由于$self->{additional}　为空，$$link 将被置为一个新的空OPT

也就是说，$self->{xedns}　被置为该空OPT 

后续如果再次调用 $reply->edns，

$link = \$self->{xedns} 一直指向该空OPT的地址，$$link一直为true，后面两行操作不会生效：

{% highlight perl %}
     ($$link) = grep $_->isa(qw(Net::DNS::RR::OPT)), @{$self->{additional}} unless $$link;
     $$link = new Net::DNS::RR( type => 'OPT' ) unless $$link;
{% endhighlight %}

$self->edns 总是返回空OPT

## $reply->data 发送给客户端

由于 $self->edns 为空OPT，$edns->_specified将一直为0，导致edns OPT不会被unshift到@addl

响应包丢失edns OPT

{% highlight perl %}
#Packet.pm
sub data {
    &encode;
}

sub encode {
    my ( $self, $size ) = @_;               # uncoverable pod

    my $edns = $self->edns;                 # EDNS support
    my @addl = grep !$_->isa('Net::DNS::RR::OPT'), @{$self->{additional}};
    unshift( @addl, $edns ) if $edns->_specified;
    $self->{additional} = \@addl;

    # ...
}
{% endhighlight %}
