FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN apt update && apt install -y build-essential \
    && pip install --no-cache-dir -r requirements.txt \
    && apt remove -y build-essential \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN python3 model/train.py

EXPOSE 6000

CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:6000", "app:app"]