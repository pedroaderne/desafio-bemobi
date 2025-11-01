#!/bin/bash
set -e
rm -rf tmp/pids


until pg_isready -h "$DATABASE_HOST" -U "postgres"; do
  echo "Aguardando o banco..."
  sleep 1
done

exec "$@"