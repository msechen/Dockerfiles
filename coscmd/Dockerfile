FROM python:alpine
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    HOME=/root
COPY --from=arpaulnet/s6-overlay-stage:latest / /
COPY s6-overlay /
COPY --from=jdnoob/loop:latest / /
COPY requirements.txt  / /
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update -f \
    && apk --no-cache add -f \
       bash \
       nodejs-current \
       npm \
       gcc \
       python3-dev \
       musl-dev \
       openssl \
       coreutils \
       moreutils \
       git \
       wget \
       curl \
       nano \
       tzdata \
&& npm install -g pm2 \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& python -m pip install --upgrade pip \
&& pip3 install -i https://mirrors.aliyun.com/pypi/simple/ -r requirements.txt \ 
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /tmp/* \
&& rm -rf /var/cache/apk/* \
&& rm -rf /root/.npm \
WORKDIR /root
ENTRYPOINT ["/init"]