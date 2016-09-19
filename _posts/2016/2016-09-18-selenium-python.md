---
layout: post
category: tech
title:  "Web Crawler : Selenium Python 笔记"
tagline: ""
tags: [ "selenium", "python", "crawler", "firefox" ] 
---
{% include JB/setup %}

安装firefox、python

seleium driver 列表：[http://www.seleniumhq.org/download/](http://www.seleniumhq.org/download/)，下载 Mozilla GeckoDriver：[https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases)，存到``$PATH``路径下

python模块安装：``pip install -U selenium``

参考：[pypi-selenium](https://pypi.python.org/pypi/selenium)

python-selenium函数文档：[selenium-python doc](http://selenium-python.readthedocs.io/index.html)

python基础函数文档：[python function doc](https://www.tutorialspoint.com/python/index.htm)

测试：

{% highlight perl %}
from selenium import webdriver

browser = webdriver.Firefox()

browser.get('http://www.qq.com')
print browser.title

browser.quit()
{% endhighlight %}
