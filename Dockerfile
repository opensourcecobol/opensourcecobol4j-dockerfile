FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# classpath settings
ENV CLASSPATH :/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/opensourcecobol4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar' >> ~/.bashrc

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
    curl -L -o opensourcecobol4j-v1.0.21.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.21.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.0.21.tar.gz &&\
    cd opensourcecobol4j-1.0.21 &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    rm ../opensourcecobol4j-v1.0.21.tar.gz

# Install Open COBOL ESQL 4J
RUN mkdir -p /usr/lib/Open-COBOL-ESQL-4j &&\
    curl -L -o  /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jre6.jar &&\
    cd /root &&\
    curl -L -o Open-COBOL-ESQL-4j-v1.0.3.tar.gz https://github.com/opensourcecobol/Open-COBOL-ESQL-4j/archive/refs/tags/v1.0.3.tar.gz &&\
    tar zxvf Open-COBOL-ESQL-4j-v1.0.3.tar.gz &&\
    cd Open-COBOL-ESQL-4j-1.0.3 &&\
    cp /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar dblibj/lib &&\
    cp /usr/lib/opensourcecobol4j/libcobj.jar dblibj/lib &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    rm ../Open-COBOL-ESQL-4j-v1.0.3.tar.gz

# add sample programs
ADD cobol_sample /root/cobol_sample
ADD ocesql4j_sample /root/ocesql4j_sample

WORKDIR /root/

CMD ["/bin/bash"]
