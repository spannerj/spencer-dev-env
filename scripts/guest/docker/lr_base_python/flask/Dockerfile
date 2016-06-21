######################################################################
# Dockerfile to build Flask Application Containers
# Based on CentOS
######################################################################

# Set the base image
FROM lr_base_python

# Install gunicorn and eventlet
RUN pip3 -q install gunicorn eventlet

# App images that extend this image will need to make sure this will run!! Or override it
# * Assumes application source made available in src
# * Eventlet used as an asycnhronous worker
# * Access logfile rerouted to stderr
# * Assumes entry point is application:app
# * Enables auto reload on file change 
CMD ["/usr/local/bin/gunicorn", "-k", "eventlet", "--pythonpath", "/src", "--access-logfile", "-", "application:app", "--reload"]