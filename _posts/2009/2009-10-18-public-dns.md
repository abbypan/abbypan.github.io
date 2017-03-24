---
layout: post
category : tech
title:  "公共递归DNS服务器"
tagline: "public recursive resolver"
tags : [ "recursive", "dns"]
---
{% include JB/setup %}

* TOC
{:toc}

# 公共递归服务器地址

注意，用这些DNS可能由于分布问题，导致访问部分网站速度变慢！

| 递归IP | 备注 |
| ------ | ---- |
| 8.8.8.8 | google |
| 8.8.4.4 | google |
| 208.67.222.222 | opendns |
| 208.67.220.220 | opendns |
| 114.114.115.115 | 114dns |
| 114.114.114.114 | 114dns |
| 1.2.4.8 | cnnic sdns |
| 210.2.4.8 | cnnic sdns |
| 223.5.5.5 | alidns |
| 223.6.6.6 | alidns |
| 180.76.76.76 | baidu |

# 公共递归服务器对于dns解析的影响

用户 end user (client ip) -> 公共递归 public recursive resolver (resolver ip) -> 权威 authoritative server

多数权威服务器，基于resolver ip做智能解析，假定resolver ip所在地即是用户来源，以此为依据选择智能解析应答

在传统的ISP递归、以及企业自营递归的架构下，限制了只允许区域内用户访问，权威假定resolver ip = client ip返回的应答，对用户体验不会有太大的影响

然而，开放递归对任意用户提供服务，却无法在所有国家地区的所有运营商部署服务器，此时，resolver ip与client ip大致等同的假定就不成立了

连锁反应即是，某些使用开放递归的用户，访问某些域名尤其是CDN业务域名时，可能无法获得与自己client ip相对的最优IP，体验较差

# edns-client-subnet ( google 的 ecs )

google 的 ECS 为解决 resolver ip 与　client ip 相距较远的问题，提出把client subnet做为addtional edns信息提交给权威

权威基于client subnet，而非resolver ip，进行智能解析应答

然而ecs存在一定的副作用，主要在于用户隐私泄漏，递归缓存增加

当client subnet从递归一直传到权威时，破坏了原有dns代理解析架构的半匿名特性，权威能够更加方便的分析定位出用户个人兴趣。注意，权威不一定是内容提供方，而只是第三方权威服务提供商。而由于dns查询多数基于明文，在查询链路上针对用户域名隐私窃听的风险同样增大

递归基于ecs subnet进行缓存，随着ipv6环境下subnet数据剧增，可以预期，未来ecs对递归的缓存压力随之增大

# 问题的根源

resolver ip = client ip 的假定: 在理论上其实并无根据，只是走的人多了，也就成了路

public recursive resolver 没有那么多服务器，只能传subnet到权威以保证解析质量: 其实是变相的增加权威需要识别的subnet数目 

# EIL处理方案

ndss 2017 dns privacy workshop: [EIL: Dealing with the Privacy Problem of ECS](https://github.com/abbypan/dns_test_eil)

基于上述问题，可以考虑将client subnet替换成<country, province, isp>的信息组

避免用户subnet隐私泄漏，以及ipv6 subnet数量爆涨引起的缓存问题

如果在public recursive resolver上部署eil，则相当于将resolver ip与client ip分离所引起的权威ecs subnet识别开销转移回公共递归
