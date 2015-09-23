---
layout: post
category : tech
title:  "Perl IO::Socket 裸发包"
tagline: "network"
tags : ["perl", "cpan", "socket", "network" ] 
---
{% include JB/setup %}

## 直接调用IO::Socket发http请求

{% highlight perl %}
#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket;
$|=1;


my $ip='202.38.64.10';
my $socket=IO::Socket::INET->new(
              PeerAddr=>$ip,
              PeerPort=>80,
              Proto=>"tcp",
              Type=>SOCK_STREAM)
or die "Couldn't connect to $ip 80:$@\n";

print $socket "GET /index.html \r\n\r\n";
while(my $answer=<$socket>){
        print $answer;
}

close($socket);
{% endhighlight %}
