FROM postgres:9.4

# Install the PostGIS extension
RUN apt-get update && \
	apt-get install -y postgresql-9.4-postgis-2.2 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# This user will be created as the superuser
ENV POSTGRES_USER root
ENV POSTGRES_PASSWORD superroot

# For dev use - while in the container psql will just work (useful for the provisioning)
ENV PGUSER root
ENV PGPASSWORD superroot
