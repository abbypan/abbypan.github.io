---
layout: post
category : tech
title:  "Firefox OS app 开发笔记"
tagline: ""
tags : [ "firefox", "app", "jquery" , "mobile", "ajax" ] 
---
{% include JB/setup %}

# 教程

[Your first app](https://developer.mozilla.org/zh-CN/Apps/Quickstart/Build/Your_first_app)

[系列影片：Firefox OS App 開發入門](https://developer.mozilla.org/zh-TW/Firefox_OS/Screencast_series:_App_Basics_for_Firefox_OS)

[Quick Guide For Firefox OS App Development](https://leanpub.com/quickguidefirefoxosdevelopment)

[firefox os webapi](https://wiki.mozilla.org/WebAPI)

# 开发环境

按 [使用应用管理器](https://developer.mozilla.org/zh-CN/Firefox_OS/Using_the_App_Manager) 的介绍安装``Firefox OS Simulator``

安装完毕后可以在``工具 -> web开发者``中找到相关启动项

按照前面的教程贴，需要生成一个目录，假设为myapp

编辑myapp目录下的``manifest.webapp``文件，设置权限，还有启动页面之类

在``Firefox OS Simulator``中指定该目录

剩下的就是纯 html5 + js 的开发

# xhr的ajax请求，跨域，gb2312编码

参考： [Firefox OS Tutorial : Episode 2 : Hello World](http://rominirani.com/2013/07/29/firefox-os-tutorial-episode-2-hello-world/)

先编辑``manifest.webapp``，设置权限

{% highlight json %}
"permissions": {
    "systemXHR": { "description": "ajax xhr" }
}
{% endhighlight %}

js代码示例

{% highlight js %}
var xhr = new XMLHttpRequest({mozSystem: true});
xhr.open("GET", "http://xxx.xxx.com/xxx", true);
xhr.setRequestHeader("Content-Type","text/html;charset=gb2312");

xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
        var $res = $.parseHTML(xhr.responseText,true);
        var somehtml = $res.find('#someid').html();
    }
}
xhr.send();
{% endhighlight %}


# jquery mobile 

基础教程：[jquery mobile w3c](http://www.w3school.com.cn/jquerymobile/index.asp)

本地html之间跳转时，同时传递参数：[jquery.mobile.paramsHandler](https://github.com/CameronAskew/jquery.mobile.paramsHandler)
