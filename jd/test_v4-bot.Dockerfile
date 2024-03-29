FROM registry.cn-shenzhen.aliyuncs.com/foreversoulmate/biu:test_v4
RUN echo "========= 安装必要软件 =========" \
   && apk add --no-cache -f \
   jq \
   python3 \
   py3-pip \
   zlib-dev \
   jpeg-dev \
   freetype-dev \
   pango-dev \
   && echo "========= 安装编译软件 =========" \
   && apk add --no-cache --virtual .build \
   gcc \
   python3-dev \
   musl-dev \
   libc-dev \
   && echo "========= 创建软链接 =========" \
   && ln -sf /usr/bin/python3 /usr/bin/python \
   && echo "========= 运行 pip install =========" \
   && pip3 install --upgrade pip \
   && cd $JD_DIR/jbot \
   && pip3 install -r requirements.txt \
   && npm install -g typescript \
   && echo "========= 清理 =========" \
   && apk del .build \
   && rm -rf /root/.cache /var/cache/apk/*