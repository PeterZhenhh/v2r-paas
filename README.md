
### 环境变量说明

|  名称 | 值  | 说明  |
| ------------ | ------------ | ------------ |
|  UUID |  [uuid在线生成器](https://www.uuidgenerator.net "uuid在线生成器") | 用户主ID  |
|  PORT |  80 | docker开放端口  |
|  CFKEY |  xxxx | WARP "private_key" 值  |
|  CFV6 |  2606:4700::/128 | WARP IPv6 地址，结尾加 /128  |
|  CFR1 |  1 | WARP "reserved" 值1  |
|  CFR2 |  2 | WARP "reserved" 值1  |
|  CFR3 |  3 | WARP "reserved" 值1  |

### 服务端入站(普通)

```
  /$UUID-vless
  /$UUID-vmess
  /$UUID-ss
  /$UUID-socks
  /$UUID-trojan
```

### 服务端入站(CF WARP)
#### 使用 warp-reg，注册warp
```
curl -sLo warp-reg https://github.com/badafans/warp-reg/releases/download/v1.0/main-linux-amd64 && chmod +x warp-reg && ./warp-reg
```
```
  /$UUID-vless-cf
  /$UUID-vmess-cf
  /$UUID-ss-cf
  /$UUID-socks-cf
  /$UUID-trojan-cf
```
