######################################################################
# Dockerfile to build Flask Application Containers
# Based on CentOS
######################################################################

# Set the base image
FROM lr_base_python

# Port for gunicorn
# Default to 8080, docker-compose can change this to the reserved port for this app
ENV PORT 8080

# Set the log level to DEBUG for development
ENV LOG_LEVEL DEBUG

# Set commit (for the health route) to be local for development
ENV COMMIT LOCAL

# Added this environment variable so that pytest can import the application package.
ENV PYTHONPATH /src

WORKDIR /src

# Install gunicorn and eventlet
RUN pip3 -q install gunicorn eventlet
