# team5-DB-backend

## **This is just a test for building the container for mysql**
***
### Introduction
```sh
Please watch the .env.exampl to make your own .env file
```
---

#### How to use
1. First, clone the repo from github
2. Check that if there are any changes in the init.sql file
3. If there are, delete the container and volume from the docker, then use the instruction below in the folder
4. 
```sh
docker-compose up --build -d
```
5. If there are no change, just re-open the continer, and develop starting from the last movement.
6. If you want't to change the Database given to all the user, just adds the instruction into the init.sql, and tells your coworker and PM.
