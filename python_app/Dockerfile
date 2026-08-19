
FROM python:3.12-slim AS builder

WORKDIR /app

COPY app.py .

FROM python:3.12-slim

WORKDIR /app

RUN useradd --create-home appuser

COPY --from=builder /app/app.py .

USER appuser

EXPOSE 8000

CMD ["python", "app.py"]
