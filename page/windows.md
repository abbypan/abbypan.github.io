---
layout: page
title: "Windows"
tagline: "常用软件"
---
{% include JB/setup %}

## 软件

| 软件 | 用途 | 同类备用软件 |
| ---- | ---- | ------------ |
| [FossHub](http://www.fosshub.com/) | 自由软件推荐 | 无 |
| [7zip](http://sparanoid.com/lab/7z/) | 压缩解压 | 无 |
| [ccleaner](https://www.piriform.com/ccleaner) | 清理系统 | wise care 365, 魔方 |
| [console2](http://sourceforge.net/projects/console/) | 命令行 | 参考 [What s a good alternative Windows console](http://stackoverflow.com/questions/440269/whats-a-good-alternative-windows-console) |
| [easeus partition manager](http://www.partition-tool.com) | 硬盘分区 | 无 |
| [freecommander](http://www.freecommander.com/) | 文件管理器 | 无 |
| [kitty](http://www.9bis.net/kitty/) | ssh 远程连接 | tunnelier，securecrt |
| [mipony](http://www.mipony.net/) | mediafire、megaupload等网盘文件下载 | 无 |
| [mp3tag](http://www.mp3tag.de/en/download.html) | mp3 文件信息编辑 | 无 |
| [waterfox](http://www.waterfoxproject.org/) | 浏览器 | 无 |
| abc amber chm converter | chm 转 pdf | 无 |
| apploc | 游戏乱码 | 无 |
| chart director | 画图库函数 | 无 |
| clisp | lisp 开发 | 无 |
| dosbox | dos环境模拟器 | 无 |
| dropbox | 网盘 | skydrive, baidu云网盘 |
| foxmail | 邮件管理 | outlook |
| fscapture | 截图、屏幕录像 | 无 |
| gear 变速齿轮 | 调整游戏时画面速度 | 无 |
| github for windows | 代码管理 | 无 |
| gvim | 编辑器 | emeditor |
| imagemagick | 图片处理 | 无 |
| jidian 极点郑码 | 形码输入法 | 无 |
| linuxLive USB Creator | U盘linux系统 | 无 |
| listary | 快速定位文件 | 无 |
| live project free viewer | 微软 mpp 文件查看 | 无 |
| medieval cue splitter | 根据cue分割音乐文件 | 无 |
| monaco ttf | 编程字体 | 无 |
| ms office | 办公 | openoffice |
| mydrivers 驱动精灵 | 硬件驱动 | 无 |
| navicat for mysql | mysql管理 | heidisql |
| oneKey Ghost | ghost 重装系统 | 无 |
| osfmount | 虚拟光驱 | 无 |
| pathsync | 同步文件夹 | super flexible file synchronizer |
| pdf xchange view | pdf阅读器 | adobe pdf reader |
| pdfsam | pdf 文件分割合并 | 无 |
| phpnow | apache + php + mysql 环境 | [uniform server](http://www.uniformserver.com/) |
| [process tamer](http://www.donationcoder.com/Software/Mouser/proctamer/) | 调节进程CPU占用 | 无 |
| qgifer | 从视频文件(mp4等)中提取gif | 无 |
| 腾讯TM | 聊天 | 无 |
| quod libet  | 音乐播放 | ttplayer 千千静听, qq音乐 |
| rapidee | 修改环境变量 | 无 |
| [regjump](http://technet.microsoft.com/zh-cn/sysinternals/bb963880) | 跳转到指定注册表位置 | 无 |
| skype | 聊天、视频 | 无 |
| SpeedUpMyPC | 系统加速 | 免费注册地址：http://mag.uniblue.com/stores/sp/signup |
| speq | 计算器 | 无 |
| strawberry perl | perl 开发 | 无 |
| thunder 迅雷精简版 | 下载 | 无 |
| txt2tags | 生成简单网页 | 无 |
| unlocker | 文件解锁，删除 | 无 |
| virtual box | 虚拟机 | vmware |
| vlc | 播放器 | baidu player 百度影音 |
| winpe 老毛桃u盘工具 | 重装系统 | 无 |
| winscp | sftp / ftp 客户端 | ftprush |
| wireless key view | 查看已保存的无线密码 | 无 |
| wireshark | 网络抓包 | 无 |
| wordpress WXR File Splitter (RSS XML) | wordpress备份的xml文件分割 | 无 |
| xlight ftp server | ftp 服务器 | 无 |

## 软件使用

###  IIS 7.5 的一些问题

问题：Microsoft JET Database Engine   不能更新，数据库或对象为只读

给“系统盘:WindowsServiceProfilesNetworkServiceAppDataLocalTemp”目录添加一个“Authenticated Users”的用户

问题：ASP不能用 '..' 表示父目录

双击ASP 打开编辑器——行为——启用父路径改为 true 

###  AntiVir(小红伞)设置允许Windows远程连接

Configure AntiVir -> Expert Mode -> Firewall -> 本地连接 -> Add rule -> Allow Remote Desktop Connection 

## 其他

### 用setx添加PATH环境变量

假设要添加``d:\software\phantomjs``到path环境变量：

``setx /M path "d:\software\phantomjs;%path%"``

### schtasks添加计划任务

``schtasks /create /sc minute /mo 5 /tn "some_task" /tr "perl d:\\software\\extract_some_data.pl"``

###  windows 7 关闭闹心的错误提示音

控制面板 -> 声音 -> 声音 -> 程序事件 -> 默认响声 -> 无

![win7-alarm](/assets/posts/win7-alarm.png)

### 将笔记本设置成ap热点，提供wifi接入

下载魔方：http://mofang.ithome.com/

应用 ->  一键无线共享

注意：密码好像只能设成8位数字

windows的bt之处就是，稍微不那么常用的功能，不google一下死活找不到……所以xx大师类的软件还是很节约时间的。。。

###  Windows XP的hosts文件

C:\Windows\System32\Drivers\Etc\hosts

###  Windows远程登录的设置

来源：[轻松搞定Windows XP无法远程登陆问题](http://tech.sina.com.cn/s/s/2006-09-04/094488896.shtml)

gpedit.msc启动策略组，然后在

"计算机配置-Windows设置-安全设置-本地策略-安全选项中-网络访问"

中选择

"本地账户的共享和安全模式"

将"仅来宾-本地用户以来宾身份验证"，改成"经典-本地用户以自己身份验证"

###  命令行重启/关闭系统

重启系统:``rundll32.exe user.exe,restartwindows``

关闭系统:``rundll32.exe user.exe,exitwindows``

###  Windows Sysinternals 的小工具

微软自己搞了个Windows Sysinternals 系统实用工具集合，有些挺好用的：

[Whois](http://technet.microsoft.com/zh-cn/bb897435) 查whois信息。

[RegJump](http://technet.microsoft.com/zh-cn/sysinternals/bb963880) 直接命令行输入 regjump xxxxx，就能跳到xxxxx注册表处。

果然微软自己也受不了一层一层又一层的键值嘛！

### kbdus.dll : 中文输入法无法调出的问题

中文输入法无法调出，用imetool重新设置时，中文键盘总是无法载入。

发现是C:\windows\system32\kbdus.dll丢失的问题。

在C:\WINDOWS\system32\dllcache里面把kdbus.dll找出来重新扔回去就可以了。 

### 右键菜单响应慢

修改注册表里面``HKEY_CURRENT_USER\Control Panel\desktop``的字符串MenuShowDelay的值为200或更小的数值。 

###  右键打开时CPU 99%

解决方法: 关闭“为菜单和工具提示使用过渡效果”

1、点击“开始”--“控制面板”

2、在“控制面板”里面双击“显示”

3、在“显示”属性里面点击“外观”标签页

4、在“外观”标签页里面点击“效果”

5、在“效果”对话框里面，清除“为菜单和工具提示使用过渡效果”前面的复选框接着点击两次“确定”按钮。


###  一个问题阻止windows正确检查此机器的许可证，错误代码0x80070002

小u问我的，结果google一下答案立马出来，不知道是哪种盗版xp这么有才。

F8进安全模式，再把正常机子的C:\WINDOWS\system32\oembios.bin拷过来扔到出问题的机子上就行了。

### 每次开机出现还原Active Desktop

就是开机出现还原Active Desktop，点击还原提示错误，重启状态如故。

开始-运行-GPEDIT.MSC-用户配置-管理模板-桌面-Active Desktop-禁用Active Desktop

退出，重启。 

## 命令行

###  重设网络连接

续订DHCP并重新分配IP: ipconfig /renew

刷新DHCP并重新注册DNS: ipconfig /registerdns

清理DNS缓存: ipconfig /flushdns 

###  命令行调用系统程序

任务管理器 taskmgr

远程桌面 mstsc

组策略 gpedit.msc 

## IE

###  Windows 7 : ie 9 双击打不开，只能右键用管理员权限打开

1.win+R 调出"运行"命令，输入"regedit"调出注册表编辑器，或者到C:\Windows下找到regedit.exe。

2.打开并定位注册表键位：HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main

3.右键点击"权限"，添加当前用户，赋予全部权限即可 

###  ie下有些图片无法正常显示的问题


家里电脑用ie，总有些图片无法正常显示。

查了一下是c:\windows\system32\pngfilt.dll的问题，下一个新的pngfilt.dll覆盖掉源文件，再执行regsvr32 pngfilt.dll就可以了。

###  浏览器提示证书错误，无法使用财付通付款

先检查系统时间是否正确，很可能是年份被改掉了。


## 重装系统

###  Ghost 恢复C盘后无法引导的问题

原来的XP搞得乱七八糟，找了个GHO镜像直接装上。

重启后就不能引导了，一片黑。

这个是分区的问题，D盘划在C盘前面，结果XP就傻掉了，所以——

把c:\boot.ini里面的partition(1)换成partition(2)就成了。

        [boot loader]
        timeout=0
        default=multi(0)disk(0)rdisk(0)partition(2)\WINDOWS
        [operating systems]
        multi(0)disk(0)rdisk(0)partition(2)\WINDOWS="Microsoft Windows XP Professional" /noexecute=optin /fastdetect 

### U盘启动后提示：vesamenu.c32: Not a COM32R image boot

直接按tab键，根据自动列出来的选项，键盘输入即可

###  重装显卡驱动修复Windows远程登录

又是个bt的状况。。。

远程登录莫名挂了，总是连接被重置。重装显卡驱动就好了。。。

###  “发送到桌面快捷方式”时去掉“.exe”

我的电脑->工具->文件夹选项->查看->隐藏已知文件夹类型的扩展名

选中即可。

###  XP登录时无法输入密码的问题

键盘驱动坏了，重启之后僵在登录窗口，无法输入密码。

重启进入WINPE，运行“Windows注册表编辑器”(这软件N个版本的PE都有，看来大家都喜欢@@)

在``[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon]``中设置
``DefaultUserName，DefaultPassword，AutoAdminLogon。AutoAdminLogon``置1才会开机自动登录（不用手动输密码）。

重启进入原系统，"设备管理器"->"键盘"->"Microsoft 自然PS/2 键盘"->右键，更新驱动程序。 

### 关闭Vista的用户账户控制(UAC)

控制面板 --> 用户账户和家庭安全 --> 用户账户 --> 打开或关闭用户账户控制

Win+R -> msconfig->工具->disable UAC->运行 

###  启动后自动打开Numlock键(小键盘灯亮)

        ;开机打开Numlock键
        [HKEY_USERS\.DEFAULT\Control Panel\Keyboard]
        "InitialKeyboardIndicators"="2"

###  Win7 : 安装SP1提示系统缺少必备的组件

解决见：win7sp1补丁包无法安装

把 FileRepository 里缺的文件补上，就能装了。

从去年买了笔记本就一直用的预装的系统，升级程序说缺了组件吧，还不说到底缺啥，鬼才知道它缺了啥，受不了。

从11:00拆腾到16:30，按微软官网的帮助搞来搞去，下啥KB947821查查查，下独立安装包试试试，再下iso准备刻盘。。。

服了我自己了，土啊！早点上百度知道、搜搜问问还快一点。
