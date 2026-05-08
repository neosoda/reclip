FROM python:3.12-slim

# Install ffmpeg, curl and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Ensure downloads directory exists
RUN mkdir -p downloads && chmod 777 downloads

# Environment variables
ENV PORT=3000
ENV HOST=0.0.0.0
ENV PYTHONUNBUFFERED=1

EXPOSE 3000

# Healthcheck to ensure the service is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/ || exit 1

# Start the application with gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:3000", "--workers", "2", "--timeout", "300", "app:app"]
