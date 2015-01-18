#!/bin/sh

# If empty data directory
if [ ! -f /var/lib/postgresql/9.4/main/PG_VERSION ] && [ "$DATABASE_NAME" ] && [ "$DATABASE_USER" ] && [ "$DATABASE_PASSWORD" ]
then
    # Create postgres data directory
    mkdir -p /var/lib/postgresql/9.4/main
    chown -R postgres:postgres /var/lib/postgresql/
    /sbin/setuser postgres /usr/lib/postgresql/9.4/bin/initdb /var/lib/postgresql/9.4/main/

    # Start postgresql
    /usr/bin/pg_ctlcluster "9.4" main start

    # Create users and databases here
    /sbin/setuser postgres createdb $DATABASE_NAME
    # wARNING This way the password is set is not very secure
    # to be reviewed..
    /sbin/setuser postgres psql -c "create user $DATABASE_USER password '$DATABASE_PASSWORD'"
    /sbin/setuser postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DATABASE_NAME TO $DATABASE_USER;"

    # Stop postgresql
    /usr/bin/pg_ctlcluster "9.4" main stop
fi

# Launch init process
/sbin/my_init
