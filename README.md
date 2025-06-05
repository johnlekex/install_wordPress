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


![image](https://github.com/user-attachments/assets/7dfa054d-2c1b-4702-942f-a6eb3d898e5d)

================================================================================================================
CREATE DATABASE AWS

INSERT INTO RESTART (StudentID,StudentName,RestartCity,GraduationDate) VALUES ('1','MO DEBISI','GLASGOW','2025-08-05');
INSERT INTO RESTART (StudentID,StudentName,RestartCity,GraduationDate) VALUES ('6','Ade Poju','Edinburgh','2025-08-05'),('7','kudos freeman','Edinburgh','2025-08-05'),('8','mody freeland','Edinburgh','2025-08-05'),('9','kash amudu','Glagow','2025-08-05'),('6','free jackon','Edinburgh','2025-08-05');






============================



mysql> DESC CLOUD_PRACTITIONER;
+---------------+------+------+-----+---------+-------+
| Field         | Type | Null | Key | Default | Extra |
+---------------+------+------+-----+---------+-------+
| StudentID     | int  | YES  |     | NULL    |       |
| certification | date | YES  |     | NULL    |       |
+---------------+------+------+-----+---------+-------+


================================================================================================================================
