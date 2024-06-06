---
layout: post
category: standard
title:  "NISTIR 8344: Ontology for Authentication"
tagline: ""
tags: [ "nist", "security" ] 
---
{% include JB/setup %}

* TOC
{:toc}

# intro

[NISTIR 8344: Ontology for Authentication](https://csrc.nist.gov/publications/detail/nistir/8344/draft)

主要是官话。

Authentication: prove membership or hierarchy (position)

measurement：
- 软/硬件/entity的唯一标识
- 防止标识信息的duplicated、compromised
- 信息的安全传输、保护
- human-machine 认证的可用性

Authentication is the component of the IAA process that provides a degree of assurance that the entity's assigned identity is verified.


# Authentication Ontology

Figure 1是概要图。

Authentication:
- Metrology: Security & Usability
- Trust
- Mgmt: 包含identity management(IM) 与 authorization
- Components
- Method: Confirmation (IAA, human-machine, human-human, machine-machine), Affirmation (OAA, Attribute)

# Authentication Mechanisms

Figure 2 是分类图。

Confirmation: verification of an entity to manage permission or access

Attestation: verification of a direct or indirect attribute of the object (not entity) of interest


## Class: Confirmation

Authenticate entity

### Domain: human-machine 

Authentication: initial, multi-modal, continuous
- initial: single response (yes/no), such as passwords, dedicated Authentication devices, biometrics. per session.
- continuous: behavioral biometrics used in a continuously sampling mode.
- multi-modal: combination of initial and/or continuous Authentication.

Family:
- Memorized Secret: password/PIN/picture/sound, something you know. Cognitive passwords, personal information.
- Biometric: fingerprint/facial/iris/voice, something you are. Initial/Continuous, behavioral biometrics.
- Apparatus: time-based PIN/event-based PIN/password in hardware devices/smartcards/RFID-based devices, something you have.
- Multi-Modal: combination two or more human-machine Authentication methods. multi-factor Authentication. Attribute Time/Location.

### Domain: machine-machine

machine-machine Authentication is used to:
- communication link security, such as IPSEC, TLS
- trusted deviced network
- automated(cached) human-machine Authentication
- provide other auth data, such as location
- provide trusted services, such as DNS, NTS, location.

machine-machine Authentication:
- crypto based: protocol, pre-shared key, digital signature, ....
- setup by admin, transparent to user
- can be a cached human-machine Authentication
- can link temporally, can be self-checking

### Domain: human-human

social engineer

out-of-band

## Class: Attestion

Authenticate object

### Domain: Attribute

many of the types of mechanisms used for machine-machine Confirmation Authentication may also be used in Attribute Attestation Authentication.

Family:
- Encryption: protect hash (secure storage / mac / digital signature / Merkle signature ),  symmetric encryption
- Storage: store separately
- Watermarking: representation embodied by the data rather than on the data itself. watermarking is not necessarily cryptographic, cryptography is often used to prevent manipulation of the watermark.

# Properties

IAA: identity management, Authentication, authorization

OAA: object management, Authentication, authorization

## IAA

### identity management

identity management: the issuance or adoption of a digital identity that is logically tied to a physical entity.

physical entity is based on the receipt of identification credentials from trusted parties, such as a passport, license, organizational registration.

digital identity: an artifact produced to establish a presence on the systems of interest.

### Authorization

RBAC: role-based access control 

ABAC: attribute-based access control

MAC: mandatory access control, denied all unless allowed

DAC: discretionary access control, permitted all unless denied

### Authentication

failed attempt threshold

communication with authorization

prevent others from gaining access

## OAA

### object management

the communication between OM and authentication should support, as a minimum, request permission, revocation, and acknowledgement of the request.

### authentication

when authentication of the object is required, the authentication uses the digital artifact to validate the object to the assurance level determined by the choice of attribute selection and the authentication method used.

### authorization

authorization is not considered part of the OA process but may be necessary for the management of an object.

## Trust relationships in Confirmation Authentication

Assignment Considerations: credential 的强度，例如individual-based 强于 role-based

Links of Trust
- One-Way Trust Authentication : 单向校验
- Mutual Trust Authentication: 双向校验

Multi-Level Trust Authentication: combination of one-way and mutual trust relationships

Attestation: the object is the same as what was expected

## Basic Mechanism Components

Components: Identity Representation (password, finger, signature, ...), Sensors (connection between the user and the system), Communications, Storage, Processing


# Building and Maintaining Authentication

security, deployability, usability, manageability

security Attributes:
- social engineering: Observation, Failover, Guessing, Strict following of guidelines, Data acquisition, Authenticator acquisition
- Configuration vulnerability: Server evidence repository, communication observance(MITM, replay, keylogger)
- Information leakage: packaging, help desk, reporting, feedback

deployability Attributes:
- Accessibility: Disability Considerations, Restrictions
- Cost: acceptable cost per user, acceptable cost for risk, acceptable implementation costs
- Compatibility: system, organization, authentication can be scaled

Usability Attributes:
- Effectiveness
- Efficiency
- Satisfaction

Manageability Attributes:
- Annual Costs: Admin, token, IT, Reader
- Long-Term Availability: Token, Readers or other sensors, Server hardware and software

# metrology for authentication

## security

minimizing compromise

representation, inimitable（避免仿制）, secure delivery, secure storage

## usability

effective: do the right things

efficient: doing things right

satisfaction: the willingness of the user to support authentication

