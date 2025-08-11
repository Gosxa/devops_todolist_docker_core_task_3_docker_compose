# Stage 1: Build Stage
ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION} as builder

WORKDIR /app
COPY . .

# Stage 2: Run Stage
FROM python:${PYTHON_VERSION} as run

WORKDIR /app

ENV PYTHONUNBUFFERED=1

COPY --from=builder /app .

# Устанавливаем зависимости для mysqlclient
RUN apt-get update && \
    apt-get install -y default-libmysqlclient-dev build-essential pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Обновляем pip и ставим Python-зависимости
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Убираем миграции из build stage — теперь они будут выполняться при старте
# RUN python manage.py migrate

EXPOSE 8080

# При старте контейнера: миграции + запуск сервера
ENTRYPOINT ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8080"]
