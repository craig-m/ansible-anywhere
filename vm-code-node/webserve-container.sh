#!/bin/bash

echo "starting webserver container"

docker \
    run -dit --name webserv -p 8080:80 \
    -v "$PWD/compute-readme.txt":/usr/local/apache2/htdocs/index.html httpd:2.4

echo "container started"