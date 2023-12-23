FROM centos:7 AS ROCKETMQ_DASHBOARD_BUILD
LABEL maintainer="chongh.ou <ochhgz@163.com>"

ENV MAVEN_HOME="/home/maven/apache-maven-3.8.6"

ARG ROCKETMQ_DASHBOARD_VERSION=1.0.0

RUN set -x \
    # && sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-* \
    # && yum update -y \
    && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip \
    && yum clean all -y \
    && mkdir -p /home/{console,maven} \
    && curl -SL https://archive.apache.org/dist/rocketmq/rocketmq-dashboard/${ROCKETMQ_DASHBOARD_VERSION}/rocketmq-dashboard-${ROCKETMQ_DASHBOARD_VERSION}-source-release.zip -o /home/console/rocketmq-dashboard.zip \
    && unzip /home/console/rocketmq-dashboard.zip -d /home/console/ \
    && curl -SL https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.zip -o /home/maven/maven.zip \
    && unzip /home/maven/maven.zip -d /home/maven/ \
    && export PATH=$PATH:$MAVEN_HOME/bin \
    && mv /home/console/rocketmq-dashboard-${ROCKETMQ_DASHBOARD_VERSION} /home/console/rocketmq-dashboard \
    && cd /home/console/rocketmq-dashboard \
    && mvn package -Dfile.encoding=UTF8 -Dmaven.test.skip=true -file pom.xml \
    && mv /home/console/rocketmq-dashboard/target/rocketmq-dashboard-${ROCKETMQ_DASHBOARD_VERSION}.jar /home/console/rocketmq-dashboard.jar

FROM centos:7
LABEL maintainer="chongh.ou <ochhgz@163.com>"

# 环境变量
ENV ROCKETMQ_VERSION="5.1.4" \
    BASE_DIR="/home/app" \
    ROCKETMQ_HOME="/home/app/rocketmq" \
    CONSOLE_HOME="/home/app/console" \
    TIME_ZONE="Asia/Shanghai" \
    # namesrv jvm参数
    NAMESRV_XMS=256m \
    NAMESRV_XMX=256m \
    NAMESRV_XMN=256m \
    # broker jvm参数
    BROKER_XMS=256m \
    BROKER_XMX=256m \
    BROKER_XMN=256m \
    BROKER_MDM=256m

ARG ROCKETMQ_VERSION=5.1.4

WORKDIR $BASE_DIR

COPY --from=ROCKETMQ_DASHBOARD_BUILD /home/console/rocketmq-dashboard.jar ${CONSOLE_HOME}/rocketmq-dashboard.jar

COPY ["./asset", "/tmp/asset/"]

# 定义用户信息
ARG user=app
ARG group=app
ARG uid=3000
ARG gid=3000

RUN set -x \
    # 安装jdk及其他工具
    # && sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-* \
    && yum update -y \
    && yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel net-tools vim unzip \
    && yum clean all -y \
    # 下载rocketmq压缩包
    && curl -SL https://archive.apache.org/dist/rocketmq/${ROCKETMQ_VERSION}/rocketmq-all-${ROCKETMQ_VERSION}-bin-release.zip -o /tmp/rocketmq.zip \
    && unzip /tmp/rocketmq.zip -d /home/app/ \
    && mv /home/app/rocketmq-all-${ROCKETMQ_VERSION}-bin-release /home/app/rocketmq \
    && rm -rf /tmp/rocketmq.zip \
    && ln -snf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime && echo $TIME_ZONE > /etc/timezone \
    && mkdir -p ${BASE_DIR}/data/{rocketmq,logs,console} \
    && mkdir -p ${BASE_DIR}/data/console/{config,store} \
    && mv /tmp/asset/console/users.properties ${BASE_DIR}/data/console/store \
    && mv /tmp/asset/console/* ${BASE_DIR}/data/console/config \
    && mv /tmp/asset/rocketmq/* ${ROCKETMQ_HOME}/bin \
    && mv /tmp/asset/docker/run.sh ${BASE_DIR}/run.sh \
    && mv ${ROCKETMQ_HOME}/conf ${BASE_DIR}/data/rocketmq \
    && rm -rf /tmp/asset \
    # 创建软链接
    && ln -s ${BASE_DIR}/data/logs ${BASE_DIR}/logs \
    && ln -s ${BASE_DIR}/data/rocketmq/conf ${ROCKETMQ_HOME}/conf \
    && ln -s ${BASE_DIR}/store ${ROCKETMQ_HOME}/store \
    && ln -s ${BASE_DIR}/store ${BASE_DIR}/data/rocketmq/store \
    && ln -s ${BASE_DIR}/data/console/config ${CONSOLE_HOME}/config \
    && ln -s ${BASE_DIR}/data/console/store ${CONSOLE_HOME}/store \
    # 添加组
    && groupadd -g ${gid} ${group} \
    # 添加用户
    && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    # 显示vim行号
    && echo ":set number" > ${BASE_DIR}/.vimrc \
    # 将文件和目录统一设置成644
    && chmod 644 -R ${BASE_DIR} \
    # 将目录统一设置成755
    && find ${BASE_DIR} -type d -print | xargs chmod 755 \
    # 将/home/app/rocketmq/rocketmq/bin下统一设置成755
    && chmod 755 -R ${ROCKETMQ_HOME}/bin \
    # 将/home/app/run.sh更名为/home/app/.run.sh
    && mv ${BASE_DIR}/run.sh ${BASE_DIR}/.run.sh \
    # 将/home/app/.run.sh设置为755
    && chmod 755 ${BASE_DIR}/.run.sh \
    # 统一将/home/app设置用户和组
    && chown -R ${uid}:${gid} ${BASE_DIR}

# 导出端口
EXPOSE 8080 9876 10909 10911 10912

# 工作目录
WORKDIR ${BASE_DIR}

# 匿名卷
VOLUME ${BASE_DIR}/data

# 切换用户环境
USER ${user}

#执行脚本
CMD ${BASE_DIR}/.run.sh
