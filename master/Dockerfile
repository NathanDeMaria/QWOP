FROM continuumio/anaconda

COPY . /root/master/.
RUN pip install -r /root/master/requirements.txt

EXPOSE 5000

CMD ["python", "/root/master/app.py"]
