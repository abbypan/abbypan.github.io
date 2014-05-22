---
layout: post
category : tech
title:  "ImageMagick：图片处理"
tagline: ""
tags : ["imagemagick", "image"] 
---
{% include JB/setup %}


## 缩放
``convert source.png -resize 64x64 dest.png``

## 剪切
``convert source.png -crop 100x100+0+0 dest.png``

## 批量把大图剪成多个小图

例如 source.png 可能是 100x5000 的大图，可以批量剪成100x50的多个小图

``convert source.png -crop 100x50  dst-%03d.png``

## 图片上下合并

``montage *.jpg -tile 1x2 -geometry +1+1 result.jpg``

