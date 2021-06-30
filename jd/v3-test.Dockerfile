FROM alpine:latest
ARG REPO=gitee
ARG REPO_URL=$REPO.com
ARG JD_TOOLS=jd_tools
ARG JD_TOOLS_BRANCH=dev
ARG JD_TOOLS_HOST=JD_TOOLS_$REPO
ARG JD_TOOLS_KEY="NEED_REPLACE"
ARG JD_SCRIPTS=jd_scripts
ARG JD_SCRIPTS_BRANCH=master
ARG JD_SCRIPTS_HOST=jd_scripts_$REPO
ARG JD_SCRIPTS_KEY="NEED_REPLACE"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd \
    ENABLE_HANGUP=true \
    ENABLE_WEB_PANEL=true \
    ENABLE_TG_BOT=false \
    JD_TOOLS_URL=git@$JD_TOOLS_HOST:dockere/$JD_TOOLS.git \
    JD_SCRIPTS_URL=git@$JD_SCRIPTS_HOST:dockere/$JD_SCRIPTS.git
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
    && echo $JD_TOOLS_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/$JD_TOOLS \
    && echo $JD_SCRIPTS_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/$JD_SCRIPTS \
    && chmod 600 /root/.ssh/$JD_TOOLS /root/.ssh/$JD_SCRIPTS \
    && echo -e "Host $JD_TOOLS_HOST\n\tHostname $REPO_URL\n\tIdentityFile=/root/.ssh/$JD_TOOLS\n\nHost $JD_SCRIPTS_HOST\n\tHostname $REPO_URL\n\tIdentityFile=/root/.ssh/$JD_SCRIPTS" > /root/.ssh/config \
    && echo -e "\n\nHost *\n  StrictHostKeyChecking no\n" >> /etc/ssh/ssh_config \
    && chmod 644 /root/.ssh/config \
    && ssh-keyscan $REPO_URL > /root/.ssh/known_hosts \
    && echo "========= 克隆SHELL程序 =========" \
    && git clone -b $JD_TOOLS_BRANCH $JD_TOOLS_URL $JD_DIR \
    && echo "========= 安装PM2 =========" \
    && cd $JD_DIR/panel \
    && npm install \
    && git clone -b $JD_SCRIPTS_BRANCH $JD_SCRIPTS_URL $JD_DIR/scripts \
    && cd $JD_DIR/scripts \
    && npm install \
    && npm install -g pm2 \
    && echo "========= 创建软链接 =========" \
    && ln -sf $JD_DIR/jd.sh /usr/local/bin/jd \
    && ln -sf $JD_DIR/git_pull.sh /usr/local/bin/git_pull \
    && ln -sf $JD_DIR/rm_log.sh /usr/local/bin/rm_log \
    && ln -sf $JD_DIR/csv.sh /usr/local/bin/csv \
    && ln -sf $JD_DIR/export_sharecodes.sh /usr/local/bin/export_sharecodes \
    && cp -f $JD_DIR/docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && rm -rf /root/.npm
WORKDIR $JD_DIR
ENTRYPOINT ["docker-entrypoint.sh"]