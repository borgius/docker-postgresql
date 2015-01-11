# dockerfile for PostgreSQL 9.1
# https://github.com/swcc/docker-postgresql | http://www.postgresql.org/
# Use phusion/baseimage as base image
FROM phusion/baseimage:latest

# Set environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Install postgres
RUN locale-gen en_US.UTF-8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' | tee /etc/apt/sources.list.d/pgdg.list
ADD ACCC4CF8.asc /tmp/ACCC4CF8.asc
RUN apt-key add /tmp/ACCC4CF8.asc
RUN apt-get update
RUN apt-get install -y postgresql-9.1 postgresql-contrib-9.1

# And add ``listen_addresses`` to ``/usr/local/pgsql/data/postgresql.conf``
# RUN echo "listen_addresses='*'" >> /usr/local/pgsql/data/postgresql.conf

# Add Postgres to runit
RUN mkdir /etc/service/postgres
ADD run_postgres.sh /etc/service/postgres/run
RUN chown root /etc/service/postgres/run
RUN chmod +x /etc/service/postgres/run

# And setup script
ADD build/setup.sh /etc/postgresql/setup.sh
RUN chmod +x /etc/postgresql/setup.sh

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# expose application port (Postgres runs on 5432)
EXPOSE 5432

# Use baseimage-docker's init system.
# Wrapped into a setup script to be able to create
# Your needed databases/users
CMD ["/etc/postgresql/setup.sh"]
