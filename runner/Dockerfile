FROM rocker/hadleyverse

RUN apt-get update && apt-get install tesseract-ocr -y

# Use to run locally, otherwise, QWOP_MASTER_ROOT is provided by the ECS task definition
# ENV QWOP_MASTER_ROOT http://192.168.99.100:5000

COPY . /root/runner/.
CMD ["Rscript", "/root/runner/main.R"]
