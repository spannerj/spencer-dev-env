FROM postgres:9.4

# This user will be created as the superuser
ENV POSTGRES_USER root
ENV POSTGRES_PASSWORD superroot

# Copy script into image, it will be run automatically when image is built
# It will create vagrant user for apps to use, and all dbs
#COPY workflow.sql /docker-entrypoint-initdb.d/workflow.sql
