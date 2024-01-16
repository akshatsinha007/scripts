#!/bin/bash
echo "testing connection"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "\c"

echo "deleting and creating new DB"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "REVOKE CONNECT ON DATABASE $LENS_DB FROM public; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "ALTER DATABASE $LENS_DB  allow_connections = off; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = "$LENS_DB"; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "DROP DATABASE $LENS_DB ;"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "CREATE DATABASE $LENS_DB ;"

PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "REVOKE CONNECT ON DATABASE $GIT_SENSOR_DB FROM public; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "ALTER DATABASE $GIT_SENSOR_DB  allow_connections = off; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = "$GIT_SENSOR_DB"; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "DROP DATABASE $GIT_SENSOR_DB ;"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "CREATE DATABASE $GIT_SENSOR_DB ;"

PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "REVOKE CONNECT ON DATABASE $CASBIN_DB FROM public; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "ALTER DATABASE $CASBIN_DB  allow_connections = off; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = "$CASBIN_DB"; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "DROP DATABASE $CASBIN_DB ;"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "CREATE DATABASE $CASBIN_DB ;"

PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "REVOKE CONNECT ON DATABASE $ORCHESTRATOR_DB FROM public; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "ALTER DATABASE $ORCHESTRATOR_DB  allow_connections = off; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$ORCHESTRATOR_DB'; "
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "DROP DATABASE $ORCHESTRATOR_DB ;"
PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "CREATE DATABASE $ORCHESTRATOR_DB ;"

PGPASSWORD=$PGPASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER_NAME -d $DB_NAME -t -c "\c"

echo "git cloning and doing migration"
: "${DEVTRON_BRANCH:=main}"
: "${GIT_SENSOR_BRANCH:=main}"
: "${LENS_BRANCH:=main}"

DB_CRED="$DB_USER:$DB_PASSWORD@"

git clone https://github.com/devtron-labs/git-sensor -b $GIT_SENSOR_BRANCH
git clone https://github.com/devtron-labs/devtron -b $DEVTRON_BRANCH
git clone https://github.com/devtron-labs/lens -b $LENS_BRANCH


migrate -path ./devtron/scripts/sql -database postgres://$DB_CRED$DB_HOST:$DB_PORT/$ORCHESTRATOR_DB? up;

migrate -path ./devtron/scripts/casbin  -database postgres://$DB_CRED$DB_HOST:$DB_PORT/$CASBIN_DB? up;


migrate -path ./git-sensor/scripts/sql  -database postgres://$DB_CRED$DB_HOST:$DB_PORT/$GIT_SENSOR_DB? up;


migrate -path ./lens/scripts/sql  -database postgres://$DB_CRED$DB_HOST:$DB_PORT/$LENS_DB? up;

echo "done migration"

