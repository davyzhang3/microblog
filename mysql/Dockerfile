FROM mysql:5.7

COPY ./init.sql /docker-entrypoint-initdb.d/:ro
ENV MYSQL_DATABASE=db \
    MYSQL_ROOT_PASSWORD=root
EXPOSE 3306