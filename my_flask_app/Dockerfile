FROM continuumio/miniconda3
ENV PYTHONUNBUFFERED=1
WORKDIR /home/server

RUN python3 -m venv venv
RUN /bin/bash -c "source venv/bin/activate"
RUN pip config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .