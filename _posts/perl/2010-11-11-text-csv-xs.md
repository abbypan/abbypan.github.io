---
layout: post
category : tech
title:  "Text::CSV_XS"
tagline: "解析文本"
tags : ["perl", "cpan", "csv" ] 
---
{% include JB/setup %}

注意几个参数：binary、sep_char、allow_loose_quotes

用getline将单行读入到数组

getline_hr将单行读入到hash（预先用column_names绑定hash的关键字）。 
