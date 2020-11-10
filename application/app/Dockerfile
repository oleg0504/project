FROM python:3.8

WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt

COPY app.py /app

COPY templates /app/templates
COPY static /app/static
EXPOSE 5000
CMD python app.py
