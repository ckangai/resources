# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code to the working directory
COPY . .

# Set the command to run the application using Gunicorn.
# Gunicorn is a production-ready WSGI server.
# Cloud Run automatically sets the PORT environment variable.
CMD exec gunicorn --bind 0.0.0.0:$PORT --workers 1 main:app