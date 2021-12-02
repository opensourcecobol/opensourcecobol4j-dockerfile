FROM centos:centos8

# install dependencies of opensourcecobol 4j
RUN rpm --import http://repos.azulsystems.com/RPM-GPG-KEY-azulsystems &&\
    curl -o /etc/yum.repos.d/zulu.repo http://repos.azulsystems.com/rhel/zulu.repo &&\
    dnf install -y gcc gcc-c++ make bison flex gmp-devel ncurses-devel zulu-14 unzip automake autoconf libtool

RUN ln -s /usr/bin/aclocal /usr/bin/aclocal-1.13 &&\
    ln -s /usr/bin/automake /usr/bin/automake-1.13

# create library directories
RUN mkdir /root/.java_lib

# download opensourcecobol4j 1.0.2
RUN cd /root/ &&\
    curl -L -o opensourcecobol4j.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.0.2.tar.gz &&\
    curl -L -o libcobj.jar              https://github.com/opensourcecobol/opensourcecobol4j/releases/download/v1.0.2/libcobj.jar &&\
    curl -L -o bdb.zip                  https://github.com/opensourcecobol/opensourcecobol4j/releases/download/BDB_Java_edition/je-7.5.11.zip &&\
    tar zxvf opensourcecobol4j.tar.gz &&\
    unzip bdb.zip &&\
    rm -f opensourcecobol4j.tar.gz &&\
    rm -f bdb.zip

# install libcobj
RUN cd /root/ &&\
    mv libcobj.jar .java_lib

# install BDB
RUN cd /root/ &&\
    mv je-7.5.11/lib/je-7.5.11.jar /root/.java_lib/ &&\
    rm -rf je-7.5.11

# install opensourcecobol4j
RUN cd /root/opensourcecobol4j-1.0.2/vbisam &&\
    ./configure --prefix=/usr/ &&\
    make install &&\
    cd ../ &&\
    ./configure --prefix=/usr/ --with-vbisam &&\
    make install

# classpath settings
RUN export CLASSPATH=$CLASSPATH:/root/.java_lib/je_7.5.11.jar:/root/.java_lib/libcobj.jar &&\
    echo 'export CLASSPATH=$CLASSPATH:/root/.java_lib/je_7.5.11.jar:/root/.java_lib/libcobj.jar' >> ~/.bashrc

# add a sample program
RUN mkdir /root/cobol_sample
ADD HELLO.cbl /root/cobol_sample/HELLO.cbl

WORKDIR /root/

CMD ["/bin/bash"]
