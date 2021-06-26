FROM alpine:latest
ARG SHELL_URL=git@gitee.com:dockere/env.git
ARG SHELL_BRANCH=master
ARG SHELL_KEY="NEED_REPLACE"
COPY --from=nevinee/s6-overlay-stage:latest / /
COPY --from=nevinee/loop:latest / /
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd \
    ENABLE_WEB_PANEL=true
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
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
    && rm -rf /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /root/.ssh \
    && cd /root/.ssh \
    && echo $SHELL_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa \
    && ssh-keyscan gitee.com > /root/.ssh/known_hosts \
    && echo "========= 克隆SHELL程序 =========" \
    && git config --global pull.ff only \
    && git clone -b $SHELL_BRANCH $SHELL_URL $JD_DIR \
    && cd $JD_DIR/scripts \
    && npm install \
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
    && ln -sf $JD_DIR/cknode.sh /usr/local/bin/cknode \
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
WORKDIR $JD_DIR
ENTRYPOINT ["/init"]