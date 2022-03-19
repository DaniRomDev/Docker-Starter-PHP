-- HERE YOU CAN PUT YOUR INITIAL SQL THAT RUNS ON INITIAL DOCKER BUILD
-- CREATE DATABASE INSTANCES, NEW USERS, PERMISSIONS, SEEDS, ETC.
-- https://chartio.com/resources/tutorials/how-to-grant-all-privileges-on-a-database-in-mysql/

CREATE DATABASE IF NOT EXISTS laravel_test; 
GRANT ALL PRIVILEGES ON laravel_test.* TO 'laravel'@'%';

FLUSH PRIVILEGES;
