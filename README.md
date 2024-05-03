# team5-DB-backend

## **This is a repo for building the container and set the environment for mysql**
### Introduction
```sh
Please watch the .env.exampl to make your own .env file
```
---

#### How to use
1. First, clone the repo from github
2. Add an **.env** file yourself, take .env.example for example
3. Check that if there are any changes in the init.sql file (you can just use ```sh git pull``` to get the newest before you start to do something in you local git)
4. If there are, delete the container and volume from the docker, then use the instruction below in the folder
5. 
```sh
docker-compose up --build -d
```
5. If there are no change, just use the above instruction or re-open the continer, and develop starting from the your last movement.
6. If you want to change the Database given to all the user, just adds the instruction into the init.sql, and tells your coworker and the PM.
7. Please Add data into database called Team5DBFinal, that where our project's data is.
