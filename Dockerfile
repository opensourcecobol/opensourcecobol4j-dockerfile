FROM almalinux:9.4

SHELL ["/bin/bash", "-c"]

# classpath settings
ENV CLASSPATH :/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/opensourcecobol4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar' >> ~/.bashrc

# install dependencies
RUN dnf update -y
RUN dnf install -y gcc g++ make autoconf diffutils gettext java-21-openjdk
# install sbt
RUN rm -f /etc/yum.repos.d/bintray-rpm.repo &&\
    curl -L https://www.scala-sbt.org/sbt-rpm.repo > sbt-rpm.repo &&\
    mv sbt-rpm.repo /etc/yum.repos.d/ &&\
    dnf install -y sbt

# install opensourcecobol4j
RUN cd /root &&\
    curl -L -o opensourcecobol4j-v1.1.2.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.1.2.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.1.2.tar.gz &&\
    cd opensourcecobol4j-1.1.2 &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    rm ../opensourcecobol4j-v1.1.2.tar.gz

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
