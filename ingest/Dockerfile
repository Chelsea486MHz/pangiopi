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

# Install the app
COPY --chown=$APP_USER:$APP_USER ./app.py $APP_DIR/app.py
COPY --chown=$APP_USER:$APP_USER ./piups.py $APP_DIR/piups.py
COPY --chown=$APP_USER:$APP_USER ./log_battery.py $APP_DIR/log_battery.py
COPY --chown=$APP_USER:$APP_USER ./log_gps.py $APP_DIR/log_gps.py
COPY --chown=$APP_USER:$APP_USER ./log_wap.py $APP_DIR/log_wap.py

# Run the app
CMD ["python", "app.py"]