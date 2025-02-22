## Overview

This Dockerfile sets up a production-ready Docker image for a Django application. It uses Python 3.10 and follows best practices for running Django in a containerized environment.

## Dockerfile Features

- Uses Python 3.10 slim image as the base
- Sets up a non-root user for running the application
- Installs only necessary system dependencies
- Uses pip to install Python dependencies
- Configures the application to run on port 8100
- Automatically runs Django management commands on startup

## Prerequisites

- Docker installed on your system
- A Django project with a `requirements.txt` file

## Dockerfile Breakdown

1. **Base Image**: 
   ```
   FROM python:3.10-slim
   ```
   Uses the official Python 3.10 slim image.

2. **Environment Setup**:
   ```
   ENV PYTHONUNBUFFERED 1
   WORKDIR /app
   ```
   Ensures Python output is sent straight to terminal and sets the working directory.

3. **System Updates and User Setup**:
   ```
   RUN apt-get update \
       && apt-get install -y --no-install-recommends \
           adduser \
       && addgroup --system django \
       && adduser --system --ingroup django django
   ```
   Updates package lists, installs `adduser`, and creates a system user and group for Django.

4. **Dependencies Installation**:
   ```
   COPY requirements.txt /app/
   RUN pip install --upgrade pip \
       && pip install --no-cache-dir -r requirements.txt
   ```
   Copies and installs Python dependencies.

5. **Application Setup**:
   ```
   COPY . /app/
   RUN chown -R django:django /app/
   USER django
   ```
   Copies application code, sets proper ownership, and switches to the non-root user.

6. **Port Configuration**:
   ```
   EXPOSE 8100
   ENV PORT=8100
   ```
   Exposes and sets the port for the Django application.

7. **Startup Command**:
   ```
   CMD ["sh", "-c", "python manage.py collectstatic --noinput && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8100"]
   ```
   Runs necessary Django commands and starts the server.

## Usage

1. Place this Dockerfile in your Django project root.
2. Ensure you have a `requirements.txt` file with all your Python dependencies.
3. Build the Docker image:
   ```
   docker build -t my-django-app .
   ```
4. Run the container:
   ```
   docker run -p 8100:8100 my-django-app
   ```

The application will be available at `http://localhost:8100`.

## Customization

- **Python Version**: Change the base image in the `FROM` statement if you need a different Python version.
- **Port**: Modify the `EXPOSE` and `ENV PORT` instructions, and update the `runserver` command if you need to use a different port.
- **Dependencies**: Make sure your `requirements.txt` is up to date with all necessary packages.
- **Startup Commands**: Adjust the `CMD` instruction if you need to run additional or different commands on startup.

## Security Notes

- The application runs as a non-root user (`django`) for enhanced security.
- Ensure that sensitive data (like secret keys) are not baked into the image. Use environment variables for secrets.


## Troubleshooting

If you encounter issues:
- Ensure all necessary files (including `requirements.txt`) are in the correct locations in your project.
- Verify that your Django project is correctly configured to run in a containerized environment.
- Check Docker logs for any error messages during build or runtime.
- Make sure your Django application is configured to listen on `0.0.0.0` to be accessible outside the container.