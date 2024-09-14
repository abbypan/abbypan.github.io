---
layout: post
category: crypto
title:  "Schnorr MuSig"
tagline: ""
tags: [ "schnorr", "musig", "bitcoin", "signature" , "aggregation", "nizk" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# Schnorr signature

$$
\begin{align*}
&X = xG\\
\\
&R = rG\\
&c = H(X,R,m)\\
\\
&s = r + cx\\
&sig = (R,s)\\
\\
&sG = R + cX\\
\end{align*}
$$ 


# MuSig

https://eprint.iacr.org/2018/068.pdf

n-of-n signature

rouge key attack

3-round, H(Ri) pre-commitment

$$
\begin{align*}
&X_{i} = x_{i}G \\
&L = H(X1, ..., Xn) \\
 \\
&a_{i} = H(L, X_{i}) \\
&X = Σa_{i}X_{i} \\
 \\
&R_{i} = r_{i}G \\
&R = ΣR_{i} \\
 \\
&s_{i} = r_{i} + H(X,R,m)a_{i}x_{i} \\
&s = Σs_{i} \\
 \\
&sig = (R, s) \\
 \\
&round 1: H(R_{i}) \\
&round 2: R_{i} \\
&round 3: s_{i} \\
\end{align*}
$$ 


# MuSig2

https://eprint.iacr.org/2020/1261.pdf

2-round, almost 1-round

omdl

$$
\begin{align*}
&R_{i}' = r_{i}'G \\
&R' = ΣR_{i}' \\
\\
&R_{i}'' = r_{i}''G \\
&R'' = ΣR_{i}'' \\
\\
&R_{i} = R'_{i} + bR''_{i}\\
&R = ΣR_{i}\\
\\
&b=H(X, R', R'', m)\\
&r_{i}=r'_{i}+br''_{i}\\
\\
&s_{i}=r_{i}+H(X, R, m)a_{i}x_{i}\\
&s = Σs_{i}\\
\\
&sig = (R, s)\\
\\
&round 1: R_{i}', R_{i}''\\
&round 2: s_{i}\\
\end{align*}
$$ 


# MuSig-DN

https://eprint.iacr.org/2020/1057.pdf

Deterministic Nonce  

2-round, nizk proof

$$
\begin{align*}
&sk_{i} \rightarrow x_i, u_i, k_i \\
\\
&host~key: U_{i} = u_{i}G\\
&for~NIZK~proof: k_i \\
\\
&K = \{ (X_i, U_i) | 1 \leq i \leq n \} \\
&V = H(K, m)\\
\\
&r_i = f(u_{i}V)\\
&R_i = r_{i}G\\
&R = ΣR_i\\
\\
&c = H(X, R, m)\\
\\
&s_i = r_i + ca_{i}x_{i}\\
&s = Σs_i\\
\\
&NIZK~proof: (Bulletproofs)\\
&ρ_i = RandDer(k_i, (K, m))\\
&π_i = Π.Prv(crs, (U_i, V, R_i), u_i; ρ_i)\\
\\
&round 1: R_i, π_i\\
&round 2: s_i\\
\end{align*}
$$ 
