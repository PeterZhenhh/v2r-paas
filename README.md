
### 环境变量说明

|  名称 | 值  | 说明  |
| ------------ | ------------ | ------------ |
|  UUID |  [uuid在线生成器](https://www.uuidgenerator.net "uuid在线生成器") | 用户主ID  |
|  PORT |  80 | docker开放端口  |


### 客户端配置

```
  - name: "yourName"
    type: vless
    server: yourName.workers.dev
    port: 443
    uuid: yourUuid
    alterId: 0
    cipher: auto
    udp: true
    tls: true
    #skip-cert-verify: true
    network: ws
    ws-path: /$UUID-vless
```

```
  - name: "yourName"
    type: vmess
    server: yourName.workers.dev
    port: 443
    uuid: yourUuid
    alterId: 0
    cipher: auto
    udp: true
    tls: true
    #skip-cert-verify: true
    network: ws
    ws-path: /$UUID-vmess
```
