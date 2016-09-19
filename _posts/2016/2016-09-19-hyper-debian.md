---
layout: post
category: tech
title:  "在 hyper.sh 安装debian镜像"
tagline: ""
tags: [ "hyper", "debian", "vps" ] 
---
{% include JB/setup %}

注册 [hyper.sh](https://console.hyper.sh/register/invite/1yNQ8EdkyMfMW0gLA4kmh8JKG4d8xYSb) 帐号

生成 [credential](https://console.hyper.sh/account/credential)，获取 Access Key, Secret Key

{% highlight bash %}
$ wget https://hyper-install.s3.amazonaws.com/hyper-linux-x86_64.tar.gz
$ tar zxvf hyper-linux-x86_64.tar.gz 
$ chmod +x hyper
$ mv hyper /usr/bin/
$ hyper config
#输入 Access Key, Secret Key
$ hyper pull debian:latest
$ hyper run --size s2 --name mydebian -p 22 -i -t debian:latest bash
root@88888888ca80:~# apt-get update
root@88888888ca80:~# apt-get intall vim ssh net-tools wget
root@88888888ca80:~# /etc/init.d/ssh start
root@88888888ca80:~# exit
$ hyper fip allocate 1
209.177.90.77
$ hyper fip attach 209.177.90.77 mydebian
$ hyper exec -it mydebian bash
root@88888888ca80:~# passwd 
#修改密码
root@88888888ca80:~# exit
{% endhighlight %}

## 远程ssh登录镜像

ssh root@209.177.90.77

## 删除image

hyper rmi debian:testing
