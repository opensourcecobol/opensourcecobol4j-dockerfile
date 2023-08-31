FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# classpath settings
ENV CLASSPATH :/usr/lib/opensourcecobol4j/sqlite.jar:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/opensourcecobol4j/postgresql.jar:/usr/lib/opensourcecobol4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/sqlite.jar:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/opensourcecobol4j/postgresql.jar:/usr/lib/opensourcecobol4j/ocesql4j.jar' >> ~/.bashrc

# install dependencies
RUN apt-get update
RUN apt-get install -y default-jdk build-essential bison flex gettext texinfo autoconf unzip zip gnupg
# install sbt
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list &&\
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list &&\
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add 
RUN apt-get update && apt-get install -y sbt

# install opensourcecobol4j
RUN cd /root &&\
    curl -L -o opensourcecobol4j-v1.0.14.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.14.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.0.14.tar.gz &&\
    cd opensourcecobol4j-1.0.14 &&\
    curl -L -o libcobj/sqlite-jdbc/sqlite.jar https://github.com/xerial/sqlite-jdbc/releases/download/3.36.0.3/sqlite-jdbc-3.36.0.3.jar &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install

# Install Open COBOL ESQL 4J
RUN curl -L -o  /usr/lib/opensourcecobol4j/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jre6.jar &&\
    curl -L -o Open-COBOL-ESQL-4j-v1.0.3.tar.gz https://github.com/opensourcecobol/Open-COBOL-ESQL-4j/archive/refs/tags/v1.0.3.tar.gz &&\
    tar zxvf Open-COBOL-ESQL-4j-v1.0.3.tar.gz &&\
    cd Open-COBOL-ESQL-4j-1.0.3 &&\
    cp /usr/lib/opensourcecobol4j/postgresql.jar dblibj/lib &&\
    cp /usr/lib/opensourcecobol4j/libcobj.jar dblibj/lib &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install

# add a sample program
RUN mkdir /root/cobol_sample
ADD HELLO.cbl /root/cobol_sample/HELLO.cbl

WORKDIR /root/

CMD ["/bin/bash"]
