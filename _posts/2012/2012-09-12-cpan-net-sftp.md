---
layout: post
category : tech
title:  "perl Net::SFTP 通过sftp传文件"
tagline: "ftp"
tags : ["perl", "cpan", "sftp" ] 
---
{% include JB/setup %}

### Net::SFTP 提示 Can't bind socket to port 1023: Address already in use

Can't bind socket to port 1023: Address already in use

初始化的时候加上``privileged=>0``参数即可

{% highlight perl %}
my $sftp = Net::SFTP->new(
       $ip,
       user => $user,
       password => $password,
       ssh_args => [ port => $port, privileged=>0 ],
 );
{% endhighlight %}

### 单行命令

需要安装 lftp

{% highlight bash %}
lftp sftp://usr:passwd@remote.host.com  -e "put some.txt; bye"

lftp -e 'mirror -R /local/somedata/ /remote/backup/' -u usr,passwd remote.host.com

lftp -e 'set net:timeout 10; cd somedir;mput *.csv; bye' -u someusr,somepw abc.xxx.com:4329
{% endhighlight %}