FROM python:alpine
ARG JD_SCRIPTS_URL=git@gitee.com:dockere/env.git
ARG JD_SCRIPTS_BRANCH=master
ARG JD_SCRIPTS_KEY="NEED_REPLACE"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    JD_DIR=/jd
COPY --from=arpaulnet/s6-overlay-stage:latest / /
COPY --from=jdnoob/loop:latest / /
WORKDIR $JD_DIR
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
       gcc \
       python3-dev \
       musl-dev \
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
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& mkdir -p /root/.ssh \
&& cd /root/.ssh \
&& echo $JD_SCRIPTS_KEY | perl -pe "{s|_| |g; s|@|\n|g}" > /root/.ssh/id_rsa \
&& chmod 600 /root/.ssh/id_rsa \
&& ssh-keyscan gitee.com > /root/.ssh/known_hosts \
 && git clone -b $JD_SCRIPTS_BRANCH $JD_SCRIPTS_URL $JD_DIR \
&& cd $JD_DIR/scripts \
&& npm install \
&& echo "========= 创建软链接 =========" \
&& ln -sf $JD_DIR/upload.sh /usr/local/bin/upload \
&& ln -sf $JD_DIR/jup.sh /usr/local/bin/jup \
&& python -m pip install --upgrade pip \
&& pip3 install -i https://mirrors.aliyun.com/pypi/simple/ -r requirements.txt \ 
&& if [ -d /etc/services.d ]; then \
    rm -rf /etc/services.d; \
    fi \
&& ln -sf $JD_DIR/s6-overlay/etc/services.d /etc/services.d \
&& echo "========= 清理 =========" \
&& rm -rf /root/.npm /var/cache/apk/*
ENTRYPOINT ["/init"]