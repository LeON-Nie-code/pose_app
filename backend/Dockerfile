FROM continuumio/miniconda3
ENV PYTHONUNBUFFERED=1
WORKDIR .
RUN for url in  \
    https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main  \
    https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r  \
    https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2; \
    do conda config --add channels $url; done
COPY environment.yml .
RUN conda env update -n base -f environment.yml
COPY . .