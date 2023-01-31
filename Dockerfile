FROM ubuntu:22.04

# install dependencies of opensourcecobol 4j
RUN apt-get update &&\
    apt-get install -y default-jdk &&\
    apt-get install -y build-essential bison flex gettext texinfo libgmp-dev autoconf

# create library directories
RUN mkdir /root/.java_lib

# install SQLite JDBC driver
RUN curl -L -o /root/.java_lib/sqlite.jar https://github.com/xerial/sqlite-jdbc/releases/download/3.36.0.3/sqlite-jdbc-3.36.0.3.jar
ENV CLASSPATH :/root/.java_lib/sqlite.jar

# install opensourcecobol4j
RUN cd /root &&\
    curl -L -o opensourcecobol4j-v1.0.7.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.7.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.0.7.tar.gz &&\
    cd opensourcecobol4j-1.0.7 &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install

# classpath settings
ENV CLASSPATH :/root/.java_lib/sqlite.jar:/usr/lib/opensourcecobol4j/libcobj.jar
RUN echo 'export CLASSPATH=:/root/.java_lib/sqlite.jar:/usr/lib/opensourcecobol4j/libcobj.jar' >> ~/.bashrc

# add a sample program
RUN mkdir /root/cobol_sample
ADD HELLO.cbl /root/cobol_sample/HELLO.cbl

WORKDIR /root/

CMD ["/bin/bash"]
