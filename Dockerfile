FROM python:3.11-slim

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create directory for SQLite database and set permissions
RUN mkdir -p /app/data && \
    chown -R appuser:appuser /app

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Health check for Kubernetes
HEALTHCHECK CMD curl -f http://localhost:8000/api/health || exit 1

# Start application with production server
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--log-level", "debug", "app:app"]
