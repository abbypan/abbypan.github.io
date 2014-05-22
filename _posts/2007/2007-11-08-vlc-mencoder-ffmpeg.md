---
layout: post
category : tech
title:  "mencoder / ffmpeg / vlc 处理视频、音频"
tagline: ""
tags : [ "vlc", "mencoder", "ffmpeg", "audio", "video", "mplayer", "lame" ] 
---
{% include JB/setup %}

## 下载在线视频

{% highlight bash %}
vlc -vvv http://coursematerials.stanford.edu/courses/ee380/130515-ee380-300.asx :dshow-vdev="USB Video Device" --sout=#transcode{vcodec=mp2v,fps=60,width=1080,acodec=mp2a,scale=1,channels=2,deinterlace,audio-sync}:standard{access-file,mux=ps,dst="test.mpg}

mplayer -dumpstream "rtsp://xxx.xxx.xxx/yyy.rm" -dumpfile yyy.rm
mplayer -dumpstream -dumpfile tiaoma.wmv mms://tv6.ustc.edu.cn/tv2
mplayer -dumpstream "mms://58.48.156.93/hubeitiyu" -dumpfile xiantao-1.wmv 

mencoder mms://xxx.xxx.xxx/zzz.wmv -ovc copy -oac copy -o zzz.wmv
{% endhighlight %}

## 转换视频格式

{% highlight bash %}
#target可以选vcd, svcd, dvd, dv，前缀可以加pal, ntsc, film，比如 ntsc-vcd。
ffmpeg -i file.avi -sameq -target vcd file.mpg
ffmpeg -i file.avi file.flv

mencoder file.wmv -ovc lavc -oac copy -ofps 23.976 -o file.avi
mencoder movie.wmv -ovc lavc -oac mp3lame -of mpeg -o movie.mpg
{% endhighlight %}

## 提取音频

flv -> wav -> mp3

{% highlight bash %}
mplayer -vc dummy -vo null -ao pcm:waveheader:file=file.wav file.flv
lame -V0 -h -b 192 --vbr-new file.wav file.mp3
ffmpeg -i video.mpg -f mp3 audio.mp3
{% endhighlight %}

## 切割视频

    ffmpeg -hq -ss 00:01:00 -t 00:05:30 -i file.avi -target svcd cut.mpg

    -t 表示的是截取视频的长度，而不是指停止时间

    avisplit -s 200 -i file.avi


## 对已有视频加音频

    mencoder -audiofile audio.wav -oac mp3lame -ovc copy video.avi -o new_video.avi

