FROM python:3.6.13-alpine
ARG JD_BASE_URL=https://gitee.com/dockere/jd-base.git
ARG JD_BASE_BRANCH=py
ARG JD_SCRIPTS_URL=git@gitee.com:dockere/jd_scripts.git
ARG JD_SCRIPTS_BRANCH=master
ARG JD_SCRIPTS_KEY="NEED_REPLACE"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd \
    ENABLE_HANGUP=true \
    ENABLE_WEB_PANEL=true
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
                             tzdata \
                             nodejs \
                             npm \
                             coreutils \
                             moreutils \
                             git \
                             wget \
                             curl \
                             nano \
                             tzdata \
                             perl \
                             openssl \
                             make \
                             gcc \
                             g++ \
                             libc-dev \
                             musl-dev \
                             musl \
                             autoconf \ 
                             libtool \
                             openssh \
                             yarn \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && cd /root/.ssh \
    && echo $JD_SCRIPTS_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/id_rsa \
    && chmod 600 /root/.ssh/id_rsa \
    && ssh-keyscan gitee.com > /root/.ssh/known_hosts \
    && git clone -b $JD_BASE_BRANCH $JD_BASE_URL $JD_DIR \
    && cd $JD_DIR/panel \
    && npm install \
    && git clone -b $JD_SCRIPTS_BRANCH $JD_SCRIPTS_URL $JD_DIR/scripts \
    && cd $JD_DIR/scripts \
    && npm install \
    && npm install -g pm2 websocketserver \
    && pip --no-cache-dir install aiohttp requests wasmtime rsa \
    && ln -sf $JD_DIR/jd.sh /usr/local/bin/jd \
    && ln -sf $JD_DIR/git_pull.sh /usr/local/bin/git_pull \
    && ln -sf $JD_DIR/rm_log.sh /usr/local/bin/rm_log \
    && ln -sf $JD_DIR/export_sharecodes.sh /usr/local/bin/export_sharecodes \
    && cp -f $JD_DIR/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh \
    && chmod 777 /usr/local/bin/docker-entrypoint.sh \
    && apk del make gcc g++ musl-dev musl autoconf build-base libffi-dev libtool \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/* \
    && rm -rf /root/.npm
WORKDIR $JD_DIR
ENTRYPOINT ["docker-entrypoint.sh"]