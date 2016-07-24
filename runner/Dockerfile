FROM rocker/hadleyverse

RUN apt-get update && apt-get install tesseract-ocr -y

ENV QWOP_MASTER_ROOT someplaceholder

COPY . /root/runner/.
CMD ["Rscript", "/root/runner/main.R"]
