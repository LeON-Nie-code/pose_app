FROM continuumio/miniconda3
ENV PYTHONUNBUFFERED=1
WORKDIR .
COPY environment.yml .
RUN conda env create -n serve -f environment.yml
COPY . .
RUN conda activate serve
