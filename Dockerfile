FROM eclipse-temurin:17

# install dependencies of opensourcecobol 4j
RUN apt update && apt install -y build-essential libgmp3-dev

RUN ln -s /usr/bin/aclocal /usr/bin/aclocal-1.13 &&\
    ln -s /usr/bin/automake /usr/bin/automake-1.13

# create library directories
RUN mkdir /root/.java_lib

# download opensourcecobol4j 1.0.3
RUN cd /root/ &&\
    curl -L -o opensourcecobol4j.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.3.tar.gz &&\
    curl -L -o libcobj.jar              https://github.com/opensourcecobol/opensourcecobol4j/releases/download/v1.0.3/libcobj-1.0.3.jar &&\
    curl -L -o sqlite.jar               https://github.com/xerial/sqlite-jdbc/releases/download/3.36.0.3/sqlite-jdbc-3.36.0.3.jar &&\
    tar zxvf opensourcecobol4j.tar.gz &&\
    rm -f opensourcecobol4j.tar.gz

# install libcobj
RUN cd /root/ &&\
    mv libcobj.jar .java_lib

# install JDBC for SQLite
RUN cd /root/ &&\
    mv sqlite.jar .java_lib

# install opensourcecobol4j
RUN cd /root/opensourcecobol4j-1.0.3/vbisam &&\
    ./configure --prefix=/usr/ &&\
    make install &&\
    cd ../ &&\
    ./configure --prefix=/usr/ --with-vbisam &&\
    make install

# classpath settings
ENV CLASSPATH=$CLASSPATH:/root/.java_lib/sqlite.jar:/root/.java_lib/libcobj.jar

WORKDIR /output
