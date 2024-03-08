#
# Build image
#
FROM python:3.11 AS image-build

RUN apt update
RUN apt install -y --no-install-recommends \
    build-essential \
    gcc
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#
# Production image
#
FROM python:3.11-slim

# Install dependencies
RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential && \
    python3-dev && \
    libgirepository1.0-dev && \
    gnupg2 && \
    liblzma-dev && \
    ffmpeg && \
    libcairo2 && \
    libcairo2-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Container settings
ENV APP_USER 'pangiopi'
ENV APP_DIR '/home/pangiopi'

# App settings
ENV DEBUG False
WORKDIR $APP_DIR
EXPOSE 5000
USER $APP_USER

# Python security
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PIP_NO_CACHE_DIR 1

# Add user and group
RUN groupadd -r -g 1000 $APP_USER && \
    useradd -r -u 1000 -g $APP_USER $APP_USER

# Install venv from the build image
COPY --from=image-build /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install the PGP data
COPY --chown=$APP_USER:$APP_USER ./pgp/. $APP_DIR/pgp

# Install the app
COPY --chown=$APP_USER:$APP_USER ./app.py $APP_DIR/app.py
COPY --chown=$APP_USER:$APP_USER ./gunicorn_config.py $APP_DIR/gunicorn_config.py

# Run the app
CMD ["gunicorn", "-c", "gunicorn_config.py", "app:app"]