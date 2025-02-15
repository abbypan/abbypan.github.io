---
layout: post
category: crypto
title:  "openssl OSSL_PARAM 的 endian 处理"
tagline: ""
tags: [ "openssl" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# background

openssl v3 之后的 [OSSL_PARAM](https://www.openssl.org/docs/man3.0/man3/OSSL_PARAM.html)

处理 OSSL_PARAM_INTEGER, OSSL_PARAM_UNSIGNED_INTEGER

是按native form的，也就是遵守system本身的big endian, little endian。

因此，[OSSL_PARAM_set_BN](https://github.com/openssl/openssl/blob/master/crypto/params.c) 内部使用`BN_bn2native`将Bignum按转成符合system endian form的raw binary，避免在little endian系统出现大小端兼容问题。

{% highlight c %}
int OSSL_PARAM_set_BN(OSSL_PARAM *p, const BIGNUM *val)
{% endhighlight %}

[EVP_PKEY_set_bn_param](https://github.com/openssl/openssl/blob/master/crypto/evp/p_lib.c)内部也有类似处理

{% highlight c %}
int EVP_PKEY_set_bn_param(EVP_PKEY *pkey, const char *key_name,
                          const BIGNUM *bn)
{% endhighlight %}


# problem 

[OSSL_PARAM_construct_BN](https://github.com/openssl/openssl/blob/master/crypto/params.c) 的value输入是`unsigned char*, size_t`，而非`BIGNUM *`，因此，调用方须自行处理endian问题。


{% highlight c %}
OSSL_PARAM OSSL_PARAM_construct_BN(const char *key, unsigned char *buf,
                                   size_t bsize)
{
    return ossl_param_construct(key, OSSL_PARAM_UNSIGNED_INTEGER,
                                buf, bsize);
}
{% endhighlight %}

# sample 

举例，将BIGNUM的priv_bn转换为natvie endian form的binary，再construct BN，能够生成以priv_bn为私钥的params。

否则，容易在hexstr, binary, bignum的转换间出错。

{% highlight c %}
BN_bn2nativepad(priv_bn, priv, priv_len);

OSSL_PARAM params[3];
params[0] = OSSL_PARAM_construct_utf8_string(OSSL_PKEY_PARAM_GROUP_NAME, (char *) group_name, 0);
params[1] = OSSL_PARAM_construct_BN(OSSL_PKEY_PARAM_PRIV_KEY, priv, priv_len);
params[2] = OSSL_PARAM_construct_end();

EVP_PKEY_fromdata(pctx, &pkey, EVP_PKEY_KEYPAIR, params);
{% endhighlight %}

因此，直接调用`EVP_PKEY_set_bn_param`更简单。
