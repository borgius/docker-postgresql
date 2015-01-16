#!/bin/sh

# If empty data directory
if [ ! -f /var/lib/postgresql/9.1/main/PG_VERSION ] && [ "$DATABASE_NAME" ] && [ "$DATABASE_USER" ] && [ "$DATABASE_PASSWORD" ]
then
    # Create postgres data directory
    mkdir -p /var/lib/postgresql/9.1/main
    chown -R postgres:postgres /var/lib/postgresql/
    /sbin/setuser postgres /usr/lib/postgresql/9.1/bin/initdb /var/lib/postgresql/9.1/main/

    # Start postgresql
    /usr/bin/pg_ctlcluster "9.1" main start

    # Create users and databases here
    /sbin/setuser postgres createdb $DATABASE_NAME
    # wARNING This way the password is set is not very secure
    # to be reviewed..
    /sbin/setuser postgres psql -c "create user $DATABASE_USER password '$DATABASE_PASSWORD'"
    /sbin/setuser postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"
    # Give access to outside world with password auth
    echo "host    all             all             172.17.0.0/16           md5
" >> /etc/postgresql/9.1/main/pg_hba.conf

    # Stop postgresql
    /usr/bin/pg_ctlcluster "9.1" main stop
fi

# Launch init process
/sbin/my_init
