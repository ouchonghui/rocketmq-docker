# Apache RocketMQ

## 简介

Apache RocketMQ 是一个具有低延迟、高性能和高可靠性、万亿级容量和灵活的分布式消息和流平台。

## 注意

本镜像基于`CentOS 8`采用Apache RocketMQ官方已发布版本进行构建，内置`net-tools`、`vim`软件方便开发者使用。

### 目录结构

```text
├─rocketmq              # rocketmq持久化目录
│  ├─conf                   
│  └─store
├─console               # 控制台持久化目录
│  ├─config
│  └─store
└─logs                  # 日志持久化目录
    ├─consolelogs
    └─rocketmqlogs
```

## 快速部署

本段指示如何快速的部署RocketMQ最新版容器。

### 拉取镜像

```shell
docker pull ochh/rocketmq:latest
```

### 创建卷

```shell
docker volume create rocketmq_data
```

### 部署镜像

```shell
# Linux 或 Mac
docker run -itd \
 --name=rocketmq \
 --restart=always \
 -p 8080:8080 \
 -p 9876:9876 \
 -p 10909:10909 \
 -p 10911:10911 \
 -p 10912:10912 \
 -v rocketmq_data:/home/app/data \
 -v /etc/localtime:/etc/localtime \
 ochh/rocketmq:latest
 
 # Windows
 docker run -itd `
 --name=rocketmq `
 --restart=always `
 -p 8080:8080 `
 -p 9876:9876 `
 -p 10909:10909 `
 -p 10911:10911 `
 -p 10912:10912 `
 -v rocketmq_data:/home/app/data `
 -v /etc/localtime:/etc/localtime `
 ochh/rocketmq:latest
```

### 控制台

```text
管理员
帐号：admin
密码：admin

普通用户
帐号：normal
密码：normal
```

### 环境变量

本镜像内置了下段中指定的环境变量，您可以结合该环境变量进行微调。

```shell
# nameserver最小堆内存，默认1024m
NAMESRV_XMS=1024m
# nameserver最大堆内存，默认1024m
NAMESRV_XMX=1024m
# nameserver年轻代内存，默认256m
NAMESRV_XMN=256m
# broker最小堆内存，默认1024m
BROKER_XMS=1024m
# broker最大堆内存，默认1024m
BROKER_XMX=1024m
# broker年轻代内存，默认256m
BROKER_XMN=256m
# broker堆外内存，默认1024m
BROKER_MDM=1024m
# 控制台nameserver地址，默认localhost:9876
NAMESRV_ADDR=localhost:9876
```

### 查看日志

```shell
docker logs rocketmq
```

### 进入容器

```shell
docker exec -it rocketmq /bin/bash
```
