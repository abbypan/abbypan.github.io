---
layout: post
category : tech
title:  "Apache 调用shell命令支持生成某些web页面内容"
tagline: "shell_exec"
tags : [ "apache", "shell" ] 
---
{% include JB/setup %}

假设
- apache运行的用户的www-data
- 需要在页面中调用的shell命令为 /usr/local/bin/xxx 和 /usr/local/bin/yyy

在/etc/sudoers中设定：
{% highlight bash %}
www-data  ALL=(ALL) NOPASSWD:/usr/local/bin/xxx,/usr/local/bin/yyy
{% endhighlight %}

在web脚本调用时要加sudo，例如``sudo xxx``

php的例子
{% highlight php %}
<?php
$id = shell_exec("sudo xxx");
echo $id;
?>     
{% endhighlight %}
