FROM almalinux:9

SHELL ["/bin/bash", "-c"]

# classpath settings
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/opensourcecobol4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar' >> ~/.bashrc

# install dependencies
RUN dnf update -y
RUN dnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel

# install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && echo Y | ./cs setup

# install opensourcecobol4j
RUN cd /root &&\
    curl -L -o opensourcecobol4j-v1.1.5.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.1.5.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.1.5.tar.gz &&\
    cd opensourcecobol4j-1.1.5 &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    rm /root/opensourcecobol4j-v1.1.5.tar.gz

# Install Open COBOL ESQL 4J
ENV PATH="$PATH:/root/.local/share/coursier/bin"
RUN mkdir -p /usr/lib/Open-COBOL-ESQL-4j &&\
    cd /root/ &&\
    curl -L -o Open-COBOL-ESQL-4j-1.1.1.tar.gz https://github.com/opensourcecobol/Open-COBOL-ESQL-4j/archive/refs/tags/v1.1.1.tar.gz &&\
    tar zxvf Open-COBOL-ESQL-4j-1.1.1.tar.gz &&\
    rm Open-COBOL-ESQL-4j-1.1.1.tar.gz &&\
    cd Open-COBOL-ESQL-4j-1.1.1 &&\
    mkdir -p /usr/lib/Open-COBOL-ESQL-4j/ &&\
    curl -L -o /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jar &&\
    cp /usr/lib/opensourcecobol4j/libcobj.jar dblibj/lib &&\
    cp /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar dblibj/lib &&\
    ./configure --prefix=/usr/ &&\
    make &&\
    make install &&\
    rm -rf /root/Open-COBOL-ESQL-4j-1.1.1

# add sample programs
ADD cobol_sample /root/cobol_sample
ADD ocesql4j_sample /root/ocesql4j_sample

WORKDIR /root/

CMD ["/bin/bash"]
