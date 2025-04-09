# Use an official lightweight Python image.
FROM python:3.12-slim-bookworm@sha256:48a11b7ba705fd53bf15248d1f94d36c39549903c5d59edcfa2f3f84126e7b44 AS base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on

WORKDIR /myapp

# Install system dependencies
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements to leverage Docker cache
COPY ./requirements.txt /myapp/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip \
    && pip install -r requirements.txt

# Copy the rest of your application's code
COPY . /myapp

# Copy the startup script and make it executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Create a non-root user and switch to it for better security
RUN useradd -m myuser
USER myuser

# Expose the port the application will run on.
EXPOSE 8000

CMD ["/start.sh"]
