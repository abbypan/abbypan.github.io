---
layout: post
category : tech
title:  "pmta : 基于DANE的支付方案"
tagline: ""
tags : [ "bitcoin", "pmta", "dane", "pmta", "pay", "dns" ] 
---
{% include JB/setup %}

Verisign 与 比特币 弄的：[Using DANE to associate payment information with email addresses](https://tools.ietf.org/html/draft-wiley-paymentassoc-00)

基于DNSSEC互联网安全基础设施，新增一个采用DANE格式的DNS RR记录PMTA，标识用户交易的支付网络、关联的账号信息，收付款方通过简单的DNS查询获得验证对方身份的有效信息。

支付双方可以自行做点对点认证，此时，平台侧负责的风险监控需求就相对弱化一些，用户侧的自主性更强一些。

在比特币网内，自行验证后交易。

如果更加理论化一点，用户相互认证后，调用资金存储平台的配套通用交易接口（需要银行支持，或者说类似银联组织的支持），就是跨行自由交易，不用paypal/alipay第三方帮忙转一道 => 最终用户对外的银行卡彻底被换成邮箱号（现实不大可能）。

技术问题在于DNSSEC部署的推进程度。
