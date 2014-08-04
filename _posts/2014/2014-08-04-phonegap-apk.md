---
layout: post
category : tech
title:  "用 phonegap 打包 app 应用为 android 的 apk 文件"
tagline: "mobile app"
tags : [ "mobile", "phonegap", "android", "apk", "html5", "js" ] 
---
{% include JB/setup %}

假设纯 html5 + js 开发的 app，假设为myapp目录，要打包成 apk 文件

## html5 + js 开发

安装 firefox os simulator ，参照firefox os app介绍，直接在浏览器调试

## 安装phonegap调试环境

按 [The PhoneGap Developer App](http://app.phonegap.com) 的说明，新建一个testapp。

拿android设备连接，则自动生成android配置文件。查看testapp目录下的``www/config.xml``、``www/index.html``两个文件。

## 打包上传

修改``www/config.xml``，设置应用名称、所需插件、应用图标等信息，拷贝到myapp目录下。

参考``www/index.html``，修改``myapp/index.html``。

打包myapp目录为zip文件，注意zip文件的根文件夹下面直接是``index.html``、``config.xml``。

在 [PhoneGap build](http://build.phonegap.com) 上新建一个myapp，将``myapp.zip``上传为该app的code。

![phonegap](/assets/posts/phonegap.png)

phonegap 网站会自动编译生成apk文件，还可以直接分享app固定网址，更新代码后不需重新提供下载链接。
