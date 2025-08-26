FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

ARG SCRIPT_NAME
ENV SCRIPT_NAME=${SCRIPT_NAME}
COPY *.py /app/

CMD ["sh", "-c", "python /app/${SCRIPT_NAME}"]