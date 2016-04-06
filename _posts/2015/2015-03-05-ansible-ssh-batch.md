---
layout: post
category : tech
title:  "ansible : ssh batch 自动化批量操作"
tagline: ""
tags : [ "ansible", "ssh", "batch"] 
---
{% include JB/setup %}

参考：[http://docs.ansible.com](http://docs.ansible.com)

# 安装

以debian为例： apt-get install ansible

# 配置 

/etc/ansible/hosts，可以配置多个分组，每个分组有多台机器

还可以批量指定分组机器的变量

{% highlight bash %}
[grpx]
xxx.qqq.cn ansible_ssh_user=root ansible_ssh_pass=xxx ansible_ssh_port=2233
yyy.qqq.cn ansible_ssh_user=root ansible_ssh_pass=xxx ansible_ssh_port=2233

[grpy]
aaa.ttt.cn ansible_ssh_user=root ansible_ssh_pass=xxx ansible_ssh_port=4455
bbb.ttt.cn ansible_ssh_user=root ansible_ssh_pass=xxx ansible_ssh_port=4455

[grpy:vars]
ansible_sudo_pass=xxx
{% endhighlight %}

# 远程机器批量操作
{% highlight bash %}
#执行指定命令
ansible grpx -a "date"
ansible grpx -a "date" --sudo
ansible grpx -a "date" --sudo --sudo-pass=12345

#执行shell指令
ansible grpx -m shell -a '/bin/echo "nameserver 8.8.8.8" > /etc/resolv.conf' --sudo

#上传本地文件到远程机器
ansible atlanta -m copy -a "src=/etc/hosts dest=/tmp/hosts"
{% endhighlight %}
