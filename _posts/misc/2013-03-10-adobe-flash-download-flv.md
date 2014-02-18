---
layout: post
category : tech
title:  "下载在线adobe flash视频，合并成flv"
tagline: "windows环境"
tags : ["adobe", "flash", "f4m", "flv"] 
---
{% include JB/setup %}

下载php：http://php.net/downloads.php，假设目录为d:\flv_download\php

下载ksv：https://github.com/K-S-V/Scripts，假设目录为d:\flv_download\ksv

## 根据manifest url自动下载

视频url：http://rutube.ru/video/eb8cbe800a676a137f99ac87351fec59/

1、firefox httpfox抓包，得到视频manifest url：
``http://video-12-7.rutube.ru/hdsv2/xacguSvukXjWWQ4Sl0JiuA/1363606322/vol41/cfab78bbb1164556861892bc9b6aa7c1_512_640x480.mp4.f4m``

2、下载并自动合并视频：
``d:\flv_download\php\php.exe  d:\flv_download\ksv\AdobeHDS.php --manifest "http://video-12-7.rutube.ru/hdsv2/xacguSvukXjWWQ4Sl0JiuA/1363606322/vol41/cfab78bbb1164556861892bc9b6aa7c1_512_640x480.mp4.f4m" --delete``


3、也可新建一个d:\flv_download\flv_download.bat：

        set /p url=<url.txt
        php\php.exe ksv\AdobeHDS.php --manifest "%url%" --delete

双击该bat，会从d:\flv_download\url.txt中自动读取f4m链接并下载视频


## 手动下载video cache合并

1、ie打开链接，播放视频

2、下载videocacheview：http://www.videohelp.com/tools/VideoCacheView

3、取出f4f视频片段，例如xxx-1.f4f，xxx-2.f4f, ...

4、合并视频为flv：

``d:\flv_download\php\php.exe d:\flv_download\ksv\AdobeHDS.php  xxx-``
