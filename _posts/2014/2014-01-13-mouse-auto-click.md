---
layout: post
category : tech
title:  "按键精灵：鼠标自动点击"
tagline: ""
tags : ["mouse"] 
---
{% include JB/setup %}

实在是七雄争霸攒了5000+个行动力卡太丧心病狂了，所以试试按键精灵

鼠标移动到指定位置，点击左键，放开左键：
    MoveTo 530, 305
    Delay 600
    LeftDown 1
    Delay 2
    LeftClick 1
    Delay 2
    LeftUp 1
    Delay 740


鼠标移动到指定位置，键盘输入退格键
    MoveTo 787, 482
    Delay 888
    KeyDown "BackSpace", 1
    Delay 58
    KeyUp "BackSpace", 1
    Delay 58

键盘输入3
    KeyDown "3", 1
    Delay 53
    KeyUp "3", 1
    Delay 113 
