---
layout: post
category: program
title:  "javascript ：从utf8页面选取内容提交到只接收gbk编码的表单乱码的问题"
tagline: ""
tags : [ "utf8", "gbk", "form", "js", "firefox", "chrome" ] 
---
{% include JB/setup %}

参考： [跨域提交form表单并转码（GBK→UTF-8）](http://happysoul.iteye.com/blog/611874)

## 问题场景

以 http://www.jjwxc.net/的小说查询为例，该表单只接收gbk编码

如果浏览器扩展从utf8页面右键取出查询关键字，点击后向其自动提交查询，则需要自动转换为gbk

## 解决方法： firefox 可用

在当前页面新建一个form，该form提交的内容与查询表单一致，同时 form.setAttribute('accept-charset','gbk');

{% highlight js %}
var JJWXC_QUERY_URL = "http://www.jjwxc.net/search.php";
var JJWXC_QUERY_TYPE = {
    "book":"1",    
    "writer":"2",  
    "lead":"4",  
    "support":"5", 
    "other":"6",
    "作品":"1",    
    "作者":"2",  
    "主角":"4",  
    "配角":"5", 
    "其他":"6"
};

function query_ljj_form(keyword, type) {
    var doc = window.content.document;
    var form=doc.createElement("form");  
    form.target='_blank';
    form.action= JJWXC_QUERY_URL;
    form.setAttribute('accept-charset', 'gbk');

    var kw = doc.createElement("input");
    kw.type="text";
    kw.name="kw";
    kw.value=keyword;
    form.appendChild(kw);

    var t = doc.createElement("input");
    t.type="text";
    t.name="t";
    t.value=JJWXC_QUERY_TYPE[type];
    form.appendChild(t);

    var s = doc.createElement("input");
    s.type="submit";
    s.value='ok';
    form.appendChild(s);

    doc.body.appendChild(form);  

    form.submit();
    doc.body.removeChild(form);
    return ;
}
{% endhighlight %}

## 解决方法： chrome可用

在当前页面新建一个iframe，该iframe中内嵌一个元素包含了需要转码的关键字，然后修改页面编码d.charset=d.characterSet="gbk";  实现编码转换后，再从该元素内取出转码后的关键字

注意，firefox中 characterSet属性是只读的，无法写入

{% highlight js %}
function getGBKEscape(s) {
    var iframe=document.createElement("iframe");  
    iframe.src="about:blank";  
    iframe.setAttribute("style","display:none;visibility:hidden;");  
    document.body.appendChild(iframe);  
    var d=iframe.contentWindow.document;  
    d.charset=d.characterSet="gbk";  
    d.write("<body><a href='?"+s+"'>gbk</a></body>");  
    d.close();  
    var url=d.body.firstChild.href;
    var gbk = url.substr(url.lastIndexOf("?")+1);  
    document.body.removeChild(iframe);
    return gbk;
}
{% endhighlight %}
