FROM alpine:3.19

LABEL maintainer="chongh.ou <ochhgz@163.com>"

# 环境变量
ENV BASE_DIR="/app" \
    ROCKETMQ_HOME="/app/rocketmq" \
    CONSOLE_HOME="/app/console" \
    DATA_DIR="/root/data" \
    TIME_ZONE="Asia/Shanghai" \
    # namesrv jvm参数
    NAMESRV_XMS=512m \
    NAMESRV_XMX=512m \
    NAMESRV_XMN=256m \
    # broker jvm参数
    BROKER_XMS=512m \
    BROKER_XMX=512m \
    BROKER_XMN=256m \
    BROKER_MDM=512m \
    # console 参数
    NAMESRV_ADDR="localhost:9876" \
    # 宿主机ip地址: 需要提供给broker.conf使用，以将broker注册地址修改为外网地址，否则默认注册的是docker内部ip地址，外部应用程序无法访问到broker
    HOST_IP="127.0.0.1"

ARG ROCKETMQ_VERSION=${ROCKETMQ_VERSION}

COPY ["./asset", "/tmp/asset/"]

RUN set -x \
    && apk add --no-cache openjdk17 curl bash \
    # 下载rocketmq压缩包
    && curl -SL https://dist.apache.org/repos/dist/release/rocketmq/${ROCKETMQ_VERSION}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release.zip -o /tmp/rocketmq.zip \
    && apk del curl \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    # 创建数据目录
    && mkdir -pv ${BASE_DIR} \
    && mkdir -pv ${DATA_DIR}/rocketmq \
    && mkdir -pv ${DATA_DIR}/console/config \
    && mkdir -pv ${DATA_DIR}/console/store \
    && mkdir -pv ${CONSOLE_HOME} \
    # 解压rocketmq压缩包
    && unzip /tmp/rocketmq.zip -d ${BASE_DIR}/ \
    && mv ${BASE_DIR}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release ${BASE_DIR}/rocketmq \
    # 移动rocketmq-dashboard
    && mv /tmp/asset/console/rocketmq-dashboard-2.1.1-SNAPSHOT.jar ${CONSOLE_HOME}/rocketmq-dashboard.jar \
    # 移动配置文件
    && mv /tmp/asset/console/users.properties ${DATA_DIR}/console/store \
    && mv /tmp/asset/console/* ${DATA_DIR}/console/config \
    && mv /tmp/asset/rocketmq/* ${ROCKETMQ_HOME}/bin \
    && mv /tmp/asset/docker/run.sh ${BASE_DIR}/run.sh \
    && mv ${ROCKETMQ_HOME}/conf ${DATA_DIR}/rocketmq \
    && rm -rf /tmp/* \
    # 创建软链接
    && ln -s ${DATA_DIR}/rocketmq/conf ${ROCKETMQ_HOME}/conf \
    && ln -s ${DATA_DIR}/console/config ${CONSOLE_HOME}/config \
    && ln -s ${DATA_DIR}/console/store ${CONSOLE_HOME}/store \
    && mv ${BASE_DIR}/run.sh ${BASE_DIR}/.run.sh \
    # 将${BASE_DIR}/.run.sh设置为755
    && chmod 755 ${BASE_DIR}/.run.sh

WORKDIR /root

# 导出端口
EXPOSE 8080 8081 8082 9876 10909 10911 10912

# 匿名卷
VOLUME ${DATA_DIR}

#执行脚本
CMD ${BASE_DIR}/.run.sh
