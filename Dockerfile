FROM eclipse-temurin:17

# install dependencies of opensourcecobol 4j
RUN apt-get update &&\
    apt-get install -y build-essential autoconf

# create library directories
RUN mkdir /root/.java_lib

# install SQLite JDBC driver
RUN curl -sS -L -o /root/.java_lib/sqlite.jar https://github.com/xerial/sqlite-jdbc/releases/download/3.36.0.3/sqlite-jdbc-3.36.0.3.jar

# install opensourcecobol4j
RUN cd /root &&\
    curl -sS -L -o opensourcecobol4j-v1.0.4.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.4.tar.gz &&\
    tar zxf opensourcecobol4j-v1.0.4.tar.gz &&\
    cd opensourcecobol4j-1.0.4 &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    cp libcobj/build/libcobj.jar ~/.java_lib

# classpath settings
ENV CLASSPATH=$CLASSPATH:/root/.java_lib/sqlite.jar:/root/.java_lib/libcobj.jar

WORKDIR /output
ENTRYPOINT ["cobc"]
