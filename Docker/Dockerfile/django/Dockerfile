# Use the official Python image from the Docker Hub
FROM python:3.10-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1

# Create and set the working directory
WORKDIR /app

# Update package lists and add necessary system users
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        adduser \
    && addgroup --system django \
    && adduser --system --ingroup django django

# Copy the requirements.txt file into the working directory
COPY requirements.txt /app/

# Install the dependencies
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the working directory
COPY . /app/

# Change ownership of the application files
RUN chown -R django:django /app/

# Switch to non-root user
USER django

# Expose the port that the Django application will run on
EXPOSE 8100
ENV PORT=8100

# Run the Django commands to collect static files, make migrations, migrate and start the server


CMD ["sh", "-c", "python manage.py collectstatic --noinput && python manage.py makemigrations && python manage.py migrate && python manage.py runserver 0.0.0.0:8100"]