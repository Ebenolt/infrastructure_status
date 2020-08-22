CREATE DATABASE `services_status`;
CREATE USER `#mysql_user#`@`%` IDENTIFIED BY `#mysql_pass#`;
GRANT ALL PRIVILEGES ON `services_status`.* TO `#mysql_user#`@`%`;
FLUSH PRIVILEGES;
