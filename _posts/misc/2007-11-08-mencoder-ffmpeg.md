---
layout: post
category : tech
title:  "mencoder / ffmpeg 处理视频、音频"
tagline: ""
tags : [ "mencoder", "ffmpeg", "audio", "video", "mplayer", "lame" ] 
---
{% include JB/setup %}

## 对已有视频加音频

    mencoder -audiofile audio.wav -oac mp3lame -ovc copy video.avi -o new_video.avi

## 视频转换

    ffmpeg -i file.avi -sameq -target vcd file.mpg

    target可以选vcd, svcd, dvd, dv，前缀可以加pal, ntsc, film，比如 ntsc-vcd。

    ffmpeg -i file.avi file.flv

    mencoder file.wmv -ovc lavc -oac copy -ofps 23.976 -o file.avi

    mencoder movie.wmv -ovc lavc -oac mp3lame -of mpeg -o movie.mpg

## 视频切割

    ffmpeg -hq -ss 00:01:00 -t 00:05:30 -i file.avi -target svcd cut.mpg

    -t 表示的是截取视频的长度，而不是指停止时间

    avisplit -s 200 -i file.avi

## 在线视频下载

    mplayer -dumpstream "rtsp://xxx.xxx.xxx/yyy.rm" -dumpfile yyy.rm

    mplayer -dumpstream -dumpfile tiaoma.wmv mms://tv6.ustc.edu.cn/tv2

    mencoder mms://xxx.xxx.xxx/zzz.wmv -ovc copy -oac copy -o zzz.wmv

    mplayer -dumpstream "mms://58.48.156.93/hubeitiyu" -dumpfile xiantao-1.wmv 


## mplayer / lame / ffmpeg 音频提取转换 flv -> wav -> mp3

    mplayer -vc dummy -vo null -ao pcm:waveheader:file=file.wav file.flv

    lame -V0 -h -b 192 --vbr-new file.wav file.mp3

    ffmpeg -i video.mpg -f mp3 audio.mp3

