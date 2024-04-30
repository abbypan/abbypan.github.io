---
layout: post
category: program
title:  "google chart 画图"
tagline: "解析文本"
tags : [ "chart" ] 
---
{% include JB/setup %}

## 示例

[how to use google charts](http://psychopyko.com/tutorial/how-to-use-google-charts/)

## 饼图

``http://chart.apis.google.com/chart?chd=t:4,6,2,1,1,1,1&cht=p3&chtt=章节更新间隔饼图&chl=季更 : 4|日更 : 6|半月更 : 2|周更 : 1|太阳黑子活动周期更 : 1|半年更 : 1|月更 : 1&chdl=季更|日更|半月更|周更|太阳黑子活动周期更|半年更|月更&chdlp=b&chts=000000,18&chs=750x300&chco=f9906f,a3d900,44cef6,48c0a3,ff0ff0,c89b40,fff143``

![google_chart_pie](/assets/posts/google_chart_pie.png)

参数参考：[chart_params](https://developers.google.com/chart/image/docs/chart_params?hl=en)

| 参数 | 作用 |
| ---- | ---- |
| chd  |  各项数值 |
| chdl  |  各项名称 |
| cht  |  google_chart 图表类型 |
| chtt  |  标题 |
| chl  |   指向分块的文字 |
| chdlp  |   图例位置 |
| chts  |  标题颜色，字体等 |
| chs | 图片大小 |
| chco | 各项填充颜色 |
