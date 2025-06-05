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



====================================================================================================

=== MySQL 8.0 Installation Complete ===
==================================================
Root password: re:St@rt!9
MySQL service is enabled and will start automatically on boot

Useful commands:
  Start MySQL:   sudo systemctl start mysqld
  Stop MySQL:    sudo systemctl stop mysqld
  Restart MySQL: sudo systemctl restart mysqld
  Check status:  sudo systemctl status mysqld
  Connect:       mysql -u root -p
