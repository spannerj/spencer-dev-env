######################################################################
# Dockerfile to build Flask Application Containers
# Based on CentOS
######################################################################

# Set the base image
FROM lr_base_python:2

# Port for gunicorn
# Default to 8080, docker-compose can change this to the reserved port for this app
ENV PORT 8080

# Set commit (for the health route) to be local for development
ENV COMMIT LOCAL

# Added this environment variable so that pytest can import the application package.
ENV PYTHONPATH /src

# Disables sendfile in gunicorn to work around a caching bug with vagrant shared folders
ENV SENDFILE 0

# If imported into your config, Flask will not cache jinja html template files.
# Best set to false in non-development regions though.
ENV TEMPLATES_AUTO_RELOAD true

WORKDIR /src

# Install gunicorn and eventlet
RUN pip3 -q install gunicorn==19.6.0 eventlet==0.19.0

# The command to run the app.
#   Eventlet is used as the (asynch) worker.
#   The python source folder is /src (mapped to outside file system in docker-compose-fragment)
#   Access log is redirected to stderr.
#   Flask app object is located in manage.py
#   Dynamic reloading is enabled.
CMD ["/usr/local/bin/gunicorn", "-k", "eventlet", "--pythonpath", "/src", "--access-logfile", "-", "manage:manager.app", "--reload"]