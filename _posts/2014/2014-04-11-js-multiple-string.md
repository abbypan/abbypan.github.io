---
layout: post
category : tech
title:  "js : 处理多行字符串"
tagline: "multiple line string"
tags : [ "js", "javascript" ] 
---
{% include JB/setup %}

参考：[Creating multiline strings in JavaScript](http://stackoverflow.com/questions/805107/creating-multiline-strings-in-javascript)

生成一个div，把多行字符串的内容放进去，但该div不显示。

提取该字符串需要在``document ready``之后。

{% highlight html %}
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>

<script>
$(document).ready( function() {

        var music_str = $('#music_data').html();
        var music_data = JSON.parse(music_str);
        var items = [];
        $.each(music_data, function(i, s) {
            items.push('<li><a href="#" data-src="' + s.url + '">' + s.artist +'-' + s.title + ','+ s.kbps + 'kpbs' + '</a></li>');
            });

        $('<ol/>', { html: items.join('') }).appendTo('#wrapper');
        });
</script>
</head>

<body>

<div id="music_data" style="display:none;">
[{"id":"106093865","artist":"周华健-张大春","title":"身在梁山","kbps":320,"format":"mp3","url":"http://zhangmenshiting.baidu.com/data2/music/106120110/106120110.mp3?xcode=8e847bc0b2a228557fb4a1542212357820101a5d66895dba","album_img":"http://musicdata.baidu.com/data2/pic/116004204/116004204.jpg"},
{"id":"2038439134","artist":"unknown","title":"周华健---身在梁山---张大春-江湖","kbps":128,"format":"mp3","url":"http://file.qianqian.com/data2/music/2038439268/2038439268.mp3?xcode=cbf6e18d70bf040c1f175c0299213b3e7c6385a2850579dc","album_img":"#"}]
</div>

<div id="wrapper">
</div>

</body>
</html>
{% endhighlight %}
