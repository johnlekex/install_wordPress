# install_wordPress
A script to install wordPress and databases and all it dependencies 

===================================================================================================
sudo -i
cd /home/ec2-user/
nano fixsql.sh #Thw fixsql Script https://tinyurl.com/2344szk2
chmod +x fixsql.sh
./fixsql.sh
mysql -u root --password='re:St@rt!9' < /home/ec2-user/world.sql
mysql -u root --password='re:St@rt!9'
