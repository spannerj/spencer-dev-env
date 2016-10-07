######################################################################
# Dockerfile to build Flask Application Containers
# Based on CentOS
######################################################################

# Set the base image
FROM lr_base_python:1

# Port for gunicorn
# Default to 8080, docker-compose can change this to the reserved port for this app
ENV PORT 8080

# Set commit (for the health route) to be local for development
ENV COMMIT LOCAL

# Added this environment variable so that pytest can import the application package.
ENV PYTHONPATH /src

# Disables sendfile in gunicorn to work around a caching bug with vagrant shared folders
ENV SENDFILE 0

# DEPERECATED: APPS SHOULD USE LOG_LEVEL INSTEAD
# WILL BE REMOVED IN VERSION 2
ENV FLASK_LOG_LEVEL DEBUG

WORKDIR /src

# Install gunicorn and eventlet
RUN pip3 -q install gunicorn eventlet

# The command to run the app.
#   Eventlet is used as the (asynch) worker.
#   The python source folder is /src (mapped to outside file system in docker-compose-fragment)
#   Access log is redirected to stderr.
#   Flask app object is located in manage.py
#   Dynamic reloading is enabled.
CMD ["/usr/local/bin/gunicorn", "-k", "eventlet", "--pythonpath", "/src", "--access-logfile", "-", "manage:manager.app", "--reload"]