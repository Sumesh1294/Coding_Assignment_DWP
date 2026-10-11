FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# Install only the required system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies separately to maximize build cache reuse
COPY app/requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

# Copy application code after installing dependencies
COPY . .

# Run the application as a non-root user
RUN useradd --create-home --shell /usr/sbin/nologin appuser \
    && chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

CMD ["gunicorn", "--chdir", "app", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
