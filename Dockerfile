FROM ubuntu
MAINTAINER Docker Education Team <education@docker.com>

# Environment settings
ENV PG_VERSION 9.2
ENV LOCALE     en_US
ENV LANGUAGE   en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Basics
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-software-properties software-properties-common language-pack-en
RUN add-apt-repository ppa:pitti/postgresql && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql-$PG_VERSION postgresql-client-$PG_VERSION postgresql-contrib-$PG_VERSION

# Locales
RUN locale-gen en_US.UTF-8
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# Important! trust means that users with no password can connect.
# On a production environment, you can either set a password for the user or
# Have postgres only be accessible locally.
RUN echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf

RUN service postgresql start && \
  su postgres sh -c "createuser -d -r -s docker" && \
  su postgres sh -c "createdb -O docker docker" && \
  su postgres sh -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE docker to docker;\""

EXPOSE 5432
CMD ["su", "postgres", "-c", "/usr/lib/postgresql/$PG_VERSION/bin/postgres -D /var/lib/postgresql/$PG_VERSION/main/ -c config_file=/etc/postgresql/$PG_VERSION/main/postgresql.conf"]
