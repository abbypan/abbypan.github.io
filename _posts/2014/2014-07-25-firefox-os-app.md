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
"type": "privileged",
"permissions": {
    "systemXHR": { "description": "ajax xhr" }
}
{% endhighlight %}

js代码示例

{% highlight js %}
var xhr = new XMLHttpRequest({mozSystem: true});
xhr.open("GET", "http://xxx.xxx.com/xxx", true); //true是异步，false是同步
xhr.overrideMimeType('text/html; charset=gb2312'); 

xhr.onreadystatechange = function() {
    if (xhr.readyState == 4) {
        var $res = $.parseHTML(xhr.responseText,true);
        var somehtml = $res.find('#someid').html();
    }
}
xhr.send();
{% endhighlight %}

# html5的localStorage本地缓存

可以用 lscache 库，支持指定缓存时间

官方接口为 localStorage.getItem / setItem 

{% highlight js %}
    var s = JSON.stringify(data);
    localStorage.setItem(key, s);

    var ds = localStorage.getItem(key);
    var d = JSON.parse(ds);
{% endhighlight %}

# jquery mobile 

基础教程：[jquery mobile w3c](http://www.w3school.com.cn/jquerymobile/index.asp)

本地html之间跳转时，同时传递参数：[jquery.mobile.paramsHandler](https://github.com/CameronAskew/jquery.mobile.paramsHandler)

## 禁止 navbar 切换page时刷新闪屏

``$.mobile.defaultPageTransition = 'none';``

## 检查checkbox是否被选中

{% highlight js %}
if($('#some_element').prop("checked")){
    alert($('#some_element').prop("value"));
}
{% endhighlight %}

## 跳转到顶部

``$.mobile.silentScroll(0);``

## 跳转到底部

``$(document).scrollTop($(document).height());``

## 等each全部执行完毕之后再执行

{% highlight js %}
var s='';
$(h).find('.some_class').each(function() {
    s+=$(this).text() + "\n";
}).promise().done(function(){
    alert(s);
});
{% endhighlight %}

## 绑定click

{% highlight js %}
$('#some_parent_node').on('click', 
'#some_click_node', function(){
    //some action
});
{% endhighlight %}

##  二层列表，支持搜索，自动展开

{% highlight html %}
<div data-role="collapsible-set" data-inset="false" data-filter="true" id="some_filter">
<div data-role="collapsible">
<h3>test1</h3>
<ul data-role="listview" data-inset="false">
<li><a href="#someurl_a">someurl_a</a></li>
<li><a href="#someurl_b">someurl_b</a></li>
</ul>
</div>
<div data-role="collapsible">
<h3>test2</h3>
<ul data-role="listview" data-inset="false">
<li><a href="#someurl_c">someurl_c</a></li>
<li><a href="#someurl_d">someurl_d</a></li>
</ul>
</div>
</div>
{% endhighlight %}

{% highlight js %}
$("#some_filter").on( "filterablefilter", function( event, ui ) {
    ui.items.each(function( index ) {
        $(this).collapsible("option", "collapsed", $(this).hasClass("ui-screen-hidden")).removeClass("ui-screen-hidden");
    });
});
{% endhighlight %}


## textarea 文本框自动调节大小

用``elastic``库

``$('textarea').elastic();``

## 夜晚模式

{% highlight html %}
<head>
<style>
</style>
</head>
<body>
<select name="night" data-role="slider" id="night_bgcolor"> 
              <option value="off">白天</option> 
              <option value="on">黑夜</option> 
              </select> 

<div id="night_css" style="display:none;">
    body,div,table  {
    background-color: #000000;
    color: #f0efd0;
    }
    a:link  { color: #71baa5; }
    a:hover {color: #FFE900 !important; background-color: #363037 !important;}
</div>
</body>
{% endhighlight %}

{% highlight js %}
$("#night_bgcolor").on("change", function () {
        var s= $(this).val()=='on' ?  $('#night_css').html() : ""; 
        $('head').find('style').html(s);
        });
{% endhighlight %}

## 调整字号
