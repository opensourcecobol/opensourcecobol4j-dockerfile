# opensource COBOL 4J development environment (Docker)

## Docker image
Versions :

- OS: Ubuntu
- opensource COBOL 4J: v1.1.4
- Open COBOL ESQL 4J: v1.1.1

In order to "Hello World" program, run the following commands in the docker container

```
cd /root/cobol_sample
cobj HELLO.cbl
java HELLO
```

## Docker containers

In order to launch the environment with a database server and a client with opensource COBOL 4J Open COBOL ESQL 4J installed, run the following command.

```bash
cd docker-compose
docker compose up -d
docker attach oc4j_client
```

Run the following in the docker container and execute sample programs of Open COBOL ESQL 4J.

```bash
cd /root/ocesql4j_sample
make
```

Copyright 2021-2024, Tokyo System House Co., Ltd. <opencobol@tsh-world.co.jp>
