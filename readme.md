# connect to database
mysql -P 3306 --protocol=tcp -u root -p  

# connect to database by entering container
docker exec -it 5756069e31b0  /bin/sh  

mysql -u root -p

password: root
# launch microblog
rm -rf migrations
docker-compose up
flask db init
flask db migrate -m "posts table'
flask db upgrade
flask run