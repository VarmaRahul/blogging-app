# --- Stage 1: Builder ---
FROM python:3.12-alpine AS builder

# 1. Install build dependencies (needed for Pillow, etc.)
RUN apk add --no-cache gcc musl-dev python3-dev libffi-dev jpeg-dev zlib-dev libjpeg zlib libffi libpq

WORKDIR /usr/src/app

# 2. Install requirements into a specific folder (wheels) to make copying easier
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


# --- Stage 2: Final Runtime ---
FROM python:3.12-alpine

# 3. Setup environment
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /usr/src/app

# 4. Install RUNTIME dependencies only (e.g., shared libs for Pillow)
RUN apk add --no-cache libjpeg zlib libffi libpq

# 5. Copy wheels from builder and install them
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy your project code
# Since your manage.py is in 'app/', we copy the contents of 'app' to the current WORKDIR
COPY ./app .
RUN python manage.py collectstatic --noinput

RUN adduser -D appuser
USER appuser

EXPOSE 8000

CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
