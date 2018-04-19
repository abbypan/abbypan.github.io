---
layout: post
category: tech
title:  "HMAC, HMAC-SHA-256, PKCS#12, OCSP相关"
tagline: ""
tags: [ "hmac", "pkcs", "pki", "ocsp", "tls" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# HMAC, RFC2104

    authentication key K

    ipad = the byte 0x36 repeated B times

    opad = the byte 0x5C repeated B times.

To compute HMAC over the data `text' we perform

    HMAC = H(K XOR opad, H(K XOR ipad, text))

也就是用K对text做处理

H函数可选SHA1, MD5, RIPEMD, 等等

# HMAC-SHA-256, RFC4868

   Block size:  the size of the data block the underlying hash algorithm
      operates upon.  For SHA-256, this is 512 bits, for SHA-384 and
      SHA-512, this is 1024 bits.

   Output length:  the size of the hash value produced by the underlying
      hash algorithm.  For SHA-256, this is 256 bits, for SHA-384 this
      is 384 bits, and for SHA-512, this is 512 bits.

   Authenticator length:  the size of the "authenticator" in bits.  This
      only applies to authentication/integrity related algorithms, and
      refers to the bit length remaining after truncation.  In this
      specification, this is always half the output length of the
      underlying hash algorithm.

注意参看2.7.2节的示例

Block size可以padding对齐，Output length长度固定，Authenticator length取Output的前一半

# PKCS#12, RFC7292

隐私模式：
- Public-key privacy mode: 信息以公钥加密(源, TPDestEncK)，以私钥解密(目标, VDestEncK)
- Password privacy mode: 信息以对称密钥加解密

完整性模式：
- Public-key integrity mode: 信息以私钥签名(源, VSrcSigK)，以公钥验证(目标, TPSrcSigK)
- Password integrity mode: 通过密码参与计算得到Message Authentication Code (MAC)进行验证

两类模式之间可以自由组合，注意 Password privacy mode 跟 Password integrity mode 的password可以不同

PFX PDU格式参考第4节。
- AuthenticatedSafe，AuthenticatedSafe后面可以带签名。AuthenticatedSafe自身带一系列ContentInfo信息，包含可能被加密的内容(content)。每个ContentInfo可以带一种类型的内容集合，例如private keys, certificates等等。
- MacData参数用于password integrity，可选项，包含MacValue(PKCS#7 Digest Info), MacSalt, iterationCount。MacKey由上述三个参数生成。

# OCSP (online certificate status protocol)

[Addressing the challenges of TLS, revocation, and OCSP](https://www.fastly.com/blog/addressing-challenges-tls-revocation-and-ocsp)

[No, don't enable revocation checking](https://www.imperialviolet.org/2014/04/19/revchecking.html)

[SSL certificate revocation and how it is broken in practice](https://medium.com/@alexeysamoshkin/how-ssl-certificate-revocation-is-broken-in-practice-af3b63b9cb3)

证书撤销的信息理论上可以用CRL批量获取、或OCSP在线逐个查询。

事实上多数浏览器采用OCSP，因为CRL文件太大没必要。

而由于ocsp存在时延、隐私问题，建议采用ocsp stapling，由服务器代理获取TLS验证所需的相关证书链信息。

google chrome的人反对ocsp主要基于时延的考虑，此外认为soft-fail模式的存在会使得攻击者阻断client->ocsp的通信，使得client接受revocated证书，对MITM攻击的防御并没有什么提升。

而避免CRL/OCSP的解决方案可以是浏览器厂商周期性更新CRL的一个子集，里面只包含"chrome/firefox认为"是"重点"的revocation信息，浏览器定时更新即可。例如chrome的CRLSet，firefox的OneCRL。优点明显，不用下载CRL的全集大文件，避免了OCSP的时延开销；缺点是人家说你重要你就重要，说你不重要你就不重要，此外就是凭什么相信某些"安全"浏览器的问题。

或者强制 [OCSP Must-Staple](https://scotthelme.co.uk/ocsp-must-staple/)，实用性有限。

问题的根源在于证书的有效时间一般一签就是几年，中途撤销信息必须能及时推送。如果OCSP Stapling + ocsp Response定期更新（例如有效期设置为几天），对多数网站是一个相对可接受的折中。

## RFC6066

[RFC6066, Section 8 Certificate Status Request](https://tools.ietf.org/html/rfc6066#page-14)

ocsp请求的数据结构，其中ResponderID是指client信任的CSP responders列表，如果列表为空则表示server已预先知道这些responders无需重复指定。

         struct {
              CertificateStatusType status_type;
              select (status_type) {
                  case ocsp: OCSPStatusRequest;
              } request;
          } CertificateStatusRequest;

          enum { ocsp(1), (255) } CertificateStatusType;

          struct {
              ResponderID responder_id_list<0..2^16-1>;
              Extensions  request_extensions;
          } OCSPStatusRequest;

          opaque ResponderID<1..2^16-1>;
          opaque Extensions<0..2^16-1>;

ocsp应答的数据结构

     struct {
          CertificateStatusType status_type;
          select (status_type) {
              case ocsp: OCSPResponse;
          } response;
      } CertificateStatus;

      opaque OCSPResponse<1..2^24-1>;

## RFC6960

[RFC6960 X.509 Internet Public Key Infrastructure Online Certificate Status Protocol - OCSP](https://tools.ietf.org/html/rfc6960)

4.1.1 节是OCSP Request格式说明，4.2.1 节是OCSP Response格式说明

    ResponseData ::= SEQUENCE {
      version              [0] EXPLICIT Version DEFAULT v1,
      responderID              ResponderID,
      producedAt               GeneralizedTime,
      responses                SEQUENCE OF SingleResponse,
      responseExtensions   [1] EXPLICIT Extensions OPTIONAL }

    SingleResponse ::= SEQUENCE {
          certID                       CertID,
          certStatus                   CertStatus,
          thisUpdate                   GeneralizedTime,
          nextUpdate         [0]       EXPLICIT GeneralizedTime OPTIONAL,
          singleExtensions   [1]       EXPLICIT Extensions OPTIONAL }


注意看2.4节的4个时间设置，The thisUpdate and nextUpdate fields define a recommended validity interval.

     thisUpdate: responder知道该status的时间
     nextUpdate: 该status在哪个时间之前有效
     producedAt: ocsp responder签发该response的时间
     revocationTime: 该证书被撤销的时间

# ocsp Stapling

[The case for “OCSP Must-Staple”](https://www.grc.com/revocation/ocsp-must-staple.htm)

[OCSP Stapling in Firefox](https://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox/)

## RFC6961 

TLS Multiple Certificate Status Request extension

支持服务器在TLS握手时发送多个ocsp响应

请求的数据结构

    struct {
       CertificateStatusType status_type;
       uint16 request_length; /* Length of request field in bytes */
       select (status_type) {
         case ocsp: OCSPStatusRequest;
         case ocsp_multi: OCSPStatusRequest;
       } request;
     } CertificateStatusRequestItemV2;

     enum { ocsp(1), ocsp_multi(2), (255) } CertificateStatusType;

     struct {
       ResponderID responder_id_list<0..2^16-1>;
       Extensions request_extensions;
     } OCSPStatusRequest;

     opaque ResponderID<1..2^16-1>;
     opaque Extensions<0..2^16-1>;

     struct {
       CertificateStatusRequestItemV2
                        certificate_status_req_list<1..2^16-1>;
     } CertificateStatusRequestListV2;

应答的数据结构

    struct {
       CertificateStatusType status_type;
       select (status_type) {
         case ocsp: OCSPResponse;
         case ocsp_multi: OCSPResponseList;
       } response;
     } CertificateStatus;

     opaque OCSPResponse<0..2^24-1>;

     struct {
       OCSPResponse ocsp_response_list<1..2^24-1>;
     } OCSPResponseList;
