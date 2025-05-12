# 使用 Python 3.8 slim 基础镜像
FROM python:3.8-slim-bullseye

# 暴露端口
EXPOSE 7860

# 换源并安装系统依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        libgl1 \
        libgomp1 \
        libglib2.0-0 \
        libsm6 \
        libxrender1 \
        libxext6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 下载模型文件
WORKDIR /app/pp-ocrv4
RUN wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_det_infer.tar
RUN wget https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar
RUN wget https://paddleocr.bj.bcebos.com/PP-OCRv4/chinese/ch_PP-OCRv4_rec_infer.tar

# 设置工作目录
WORKDIR /app

# 复制依赖文件并安装系统依赖
COPY requirements.txt /app/requirements.txt

# 换源并安装 Python 依赖
RUN python3 -m pip install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . /app

# 创建模型目录并解压模型文件
RUN mkdir -p /root/.paddleocr/whl/cls/ && \
    mkdir -p /root/.paddleocr/whl/det/ch/ && \
    mkdir -p /root/.paddleocr/whl/rec/ch/ && \
    tar xf /app/pp-ocrv4/ch_ppocr_mobile_v2.0_cls_infer.tar -C /root/.paddleocr/whl/cls/ 2>/dev/null && \
    tar xf /app/pp-ocrv4/ch_PP-OCRv4_det_infer.tar -C /root/.paddleocr/whl/det/ch/ && \
    tar xf /app/pp-ocrv4/ch_PP-OCRv4_rec_infer.tar -C /root/.paddleocr/whl/rec/ch/ && \
    rm -rf /app/pp-ocrv4/*.tar

# 启动命令
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "7860", "--workers", "2", "--log-config", "./log_conf.yaml"]
