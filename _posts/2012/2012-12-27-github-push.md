---
layout: post
category : tech
title:  "github : 使用 ssh 公钥认证 提交代码"
tagline: ""
tags : [ "github", "git" ] 
---
{% include JB/setup %}

{% highlight perl %}
{% endhighlight %}

初始化密钥参考：https://help.github.com/articles/generating-ssh-keys

假设生成的github私钥为github_rsa，存到本地 ~/.ssh目录下

在本地~/.ssh/config中添加一段：

    Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/github_rsa

假设用户名为 someuser，在github上新建一个 somerepo，本地执行：

git clone git@github.com:someuser/somerepo.git

此时，本地somerepo文件夹内的 .git/config 文件中，会有如下内容：

[remote "origin"]
    url = git@github.com:someuser/somerepo.git
    fetch = +refs/heads/*:refs/remotes/origin/*

本地通过 git push origin master 即可使用 ssh 公钥认证，不输密码提交代码 
