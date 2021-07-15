FROM alpine:latest
ARG REPO=gitee
ARG REPO_URL=$REPO.com
ARG JD_SHELL_ENV=env
ARG JD_SHELL_ENV_BRANCH=master
ARG JD_SHELL_ENV_HOST=JD_SHELL_ENV_$REPO
ARG JD_SHELL_ENV_KEY="NEED_REPLACE"
ARG JD_SCRIPTSL_ENV=env
ARG JD_SCRIPTSL_ENV_BRANCH=dev
ARG JD_SCRIPTSL_ENV_HOST=JD_SCRIPTSL_ENV_$REPO
ARG JD_SCRIPTSL_ENV_KEY="NEED_REPLACE"
COPY --from=arpaulnet/s6-overlay-stage:latest / /
COPY --from=jdnoob/loop:latest / /
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd \
    ENABLE_RESET_REPO_URL=true \
    JD_SHELL_ENV_URL=git@$JD_SHELL_ENV_HOST:dockere/$JD_SHELL_ENV.git \
    JD_SCRIPTSL_ENV_URL=git@$JD_SCRIPTSL_ENV_HOST:dockere/$JD_SCRIPTSL_ENV.git
WORKDIR $JD_DIR
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && echo "========= 安装软件 =========" \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f \
    bash \
    coreutils \
    diffutils \
    git \
    wget \
    curl \
    nano \
    tzdata \
    perl \
    openssh-client \
    nodejs-lts \
    npm \
    && echo "========= 修改时区 =========" \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && echo "========= 部署SSH KEY =========" \
    && mkdir -p /root/.ssh \
    && echo $JD_SHELL_ENV_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/$JD_SHELL_ENV \
    && echo $JD_SCRIPTSL_ENV_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/$JD_SCRIPTSL_ENV \
    && chmod 600 /root/.ssh/$JD_SHELL_ENV /root/.ssh/$JD_SCRIPTSL_ENV \
    && echo -e "Host $JD_SHELL_ENV_HOST\n\tHostname $REPO_URL\n\tIdentityFile=/root/.ssh/$JD_SHELL_ENV\n\nHost $JD_SCRIPTSL_ENV_HOST\n\tHostname $REPO_URL\n\tIdentityFile=/root/.ssh/$JD_SCRIPTSL_ENV" > /root/.ssh/config \
    && echo -e "\n\nHost *\n  StrictHostKeyChecking no\n" >> /etc/ssh/ssh_config \
    && chmod 644 /root/.ssh/config \
    && ssh-keyscan $REPO_URL > /root/.ssh/known_hosts \
    && echo "========= 克隆SHELL程序 =========" \
    && git config --global pull.ff only \
    && git clone -b $JD_SHELL_ENV_BRANCH $JD_SHELL_ENV_URL $JD_DIR \
    && echo "========= 安装PM2 =========" \
    && npm install -g pm2 \
    && echo "========= 创建软链接 =========" \
    && ln -sf $JD_DIR/jtask.sh /usr/local/bin/jtask \
    && ln -sf $JD_DIR/jtask.sh /usr/local/bin/otask \
    && ln -sf $JD_DIR/jtask.sh /usr/local/bin/mtask \
    && ln -sf $JD_DIR/jup.sh /usr/local/bin/jup \
    && ln -sf $JD_DIR/jlog.sh /usr/local/bin/jlog \
    && ln -sf $JD_DIR/jcode.sh /usr/local/bin/jcode \
    && ln -sf $JD_DIR/jcsv.sh /usr/local/bin/jcsv \
    && ln -sf $JD_DIR/bot/key.sh /usr/local/bin/key \
    && ln -sf $JD_DIR/bot/upload.sh /usr/local/bin/upload \
    && ln -sf $JD_DIR/bot/cknode.sh /usr/local/bin/cknode \
    && if [ -d /etc/cont-init.d ]; then \
    rm -rf /etc/cont-init.d; \
    fi \
    && if [ -d /etc/services.d ]; then \
    rm -rf /etc/services.d; \
    fi \
    && ln -sf $JD_DIR/s6-overlay/etc/cont-init.d /etc/cont-init.d \
    && ln -sf $JD_DIR/s6-overlay/etc/services.d /etc/services.d \
    && echo "========= 清理 =========" \
    && rm -rf /root/.npm /var/cache/apk/*
ENTRYPOINT ["/init"]