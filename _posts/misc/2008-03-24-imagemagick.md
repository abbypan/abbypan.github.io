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

## 图片上下合并

``montage *.jpg -tile 1x2 -geometry +1+1 result.jpg``

