FROM almalinux:9

SHELL ["/bin/bash", "-c"]

# classpath settings
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar' >> ~/.bashrc

# install dependencies
RUN dnf update -y
RUN dnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel

# install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && chmod +x cs && echo Y | ./cs setup

# install opensourcecobol4j
RUN cd /root &&\
    curl -L -o opensourcecobol4j-v1.1.7.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.1.7.tar.gz &&\
    tar zxvf opensourcecobol4j-v1.1.7.tar.gz &&\
    cd opensourcecobol4j-1.1.7 &&\
    ./configure --prefix=/usr/ --enable-utf8 &&\
    touch cobj/*.m4 &&\
    make &&\
    make install &&\
    rm /root/opensourcecobol4j-v1.1.7.tar.gz

# add sample programs
ADD cobol_sample /root/cobol_sample

WORKDIR /root/

CMD ["/bin/bash"]
