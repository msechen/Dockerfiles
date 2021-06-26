FROM ubuntu:20.04
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    DEBIAN_FRONTEND=noninteractive \
    prefix=-
SHELL ["/bin/bash", "-c"]
RUN source ~/.bashrc \
    && apt-get update \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get  install -y software-properties-common \
    && add-apt-repository ppa:dawidd0811/neofetch \
    && apt-get install -y  tzdata \
    git \
    curl \
    wget \
    bash \
    x11-xserver-utils \
    neofetch \
    libzbar-dev \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-chi-sim \
    imagemagick \
    redis-server \
    python3 \
    python3-pip \
    sudo \
    && sed -e 's;^# \(%wheel.*NOPASSWD.*\);\1;g' -i /etc/sudoers \
    && mkdir -p /pagermaid/workdir \
    && git clone -b master https://github.com/Xtao-Labs/PagerMaid-Modify.git /pagermaid/workdir \
    && git clone -b master https://github.com/ekomini/docker.git /docker \
    && cp -f /docker/file/docker-run.sh /pagermaid/workdir/docker-run.sh \
    && cp -f /docker/file/listener.py /pagermaid/workdir/pagermaid/listener.py \
    && cd /pagermaid/workdir \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && pip3 install -i https://mirrors.aliyun.com/pypi/simple/ -r requirements.txt \
    && pip3 install dateparser \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /pagermaid/workdir
CMD ["sh","docker-run.sh"]