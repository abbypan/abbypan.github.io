---
layout: post
category : tech
title:  "Firefox addon sdk 开发扩展"
tagline: ""
tags : [ "firefox", "extension", "addon" ] 
---
{% include JB/setup %}

# 安装

以 archlinux 环境为例

{% highlight bash %}

$ sudo yaourt -S npm

$ sudo npm install jpm --global

$ jpm

{% endhighlight %}

参考[Using Post and Watchpost](https://www.npmjs.com/package/jpm#using-post-and-watchpost)，firefox 安装扩展 [Extension Auto-Installer](https://addons.mozilla.org/en-US/firefox/addon/autoinstaller/)

# 开发

以开发 jjwxc 扩展为例

参考 [jpm](https://developer.mozilla.org/en-US/Add-ons/SDK/Tools/jpm)

{% highlight bash %}
$ mkdir jjwxc

$ cd jjwxc

$ jpm init

# 编辑 package.json 文件

# 启动firefox，编码调试（需要预先安装 Extension Auto-Installer
$ jpm post --post-url http://localhost:8888/ -v

# 打包
$ jpm xpi

{% endhighlight %}

# 编码

参考 [firefox addon sdk](https://developer.mozilla.org/en-US/Add-ons/SDK)
