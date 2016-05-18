FROM postgres:9.4

# This user will be created as the superuser
ENV POSTGRES_USER root
ENV POSTGRES_PASSWORD superroot

# Copy generated script into image, it will be run automatically when image is built
COPY init.sql /docker-entrypoint-initdb.d/init.sql
