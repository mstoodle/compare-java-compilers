#!/bin/sh
sudo docker run --cpuset-cpus=64-79 -d --rm -p 5432:5432 --network host -e POSTGRES_DB='rest-crud' -e POSTGRES_USER='restcrud' -e POSTGRES_PASSWORD='restcrud' --name rest-crud-quarkus-db docker.io/postgres:10.5
