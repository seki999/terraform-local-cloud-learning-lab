# Lab 31 - 密码学基础与 Key Management

## 目标

理解安全工程里最常遇到的密码学组件：

- hash
- encryption
- symmetric key
- asymmetric key
- digital signature
- certificate
- key rotation

目标是理解用途，不自己发明加密算法。

## 1. Hash

Hash 用于：

- integrity
- fingerprint
- password storage 的组成部分

特点：

```text
input -> fixed-size digest
```

它不是加密，因为没有正常“解密”过程。

## 2. Password Hashing

密码不应直接存明文或通用快速 hash。

应使用专门 password hashing/KDF，例如：

- Argon2
- bcrypt
- scrypt
- PBKDF2

并配 salt。

## 3. Symmetric Encryption

同一个 secret key 用于加密/解密。

优点：

- 快
- 适合大数据

难点：

- key distribution

## 4. Asymmetric

公钥/私钥。

常用于：

- key exchange
- signature
- certificate identity

## 5. Digital Signature

签名用于证明：

- integrity
- signer possession of private key

不是用于隐藏内容。

## 6. Certificate

证书把：

```text
identity
+
public key
```

通过 CA 信任链连接起来。

## 7. Key Storage

私钥不应该：

- 提交 Git
- 写进镜像
- 出现在日志

应考虑：

- OS key store
- Vault
- KMS
- HSM

## 8. Rotation

Key rotation 需要：

```text
new key
 -> distribute
 -> dual support if needed
 -> verify
 -> revoke old
```

## 9. Envelope Encryption

云 KMS 常见思路：

```text
data encrypted with data key
data key protected by master key
```

避免直接用 master key 加密所有业务数据。

## 10. Crypto Agility

系统应能升级算法/密钥，而不是把某个算法永久写死。

## 11. Randomness

Token、nonce、key 必须使用 cryptographically secure randomness。

不要用普通伪随机函数生成安全 token。

## 12. 练习

1. 区分 hash、encryption、signature。
2. 解释 password hashing 为什么要慢。
3. 画 TLS certificate trust chain。
4. 设计 key rotation 流程。
5. 解释为什么不自己设计加密算法。

## 13. 完成标准

你应该能够为不同问题选择正确原语，而不是把“加密”当成一个笼统概念。
