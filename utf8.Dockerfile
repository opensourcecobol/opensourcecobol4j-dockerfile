# Build stage
FROM almalinux:9 AS builder

ARG opensource_COBOL_4J_version=1.1.12 Open_COBOL_ESQL_4J_version=1.1.1

SHELL ["/bin/bash", "-c"]

# install build dependencies
RUN dnf update -y && \
    dnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel && \
    dnf clean all

# install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && \
    chmod +x cs && \
    echo Y | ./cs setup

# build opensourcecobol4j
RUN cd /root && \
    curl -L -o opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v${opensource_COBOL_4J_version}.tar.gz && \
    tar zxvf opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz && \
    cd opensourcecobol4j-${opensource_COBOL_4J_version} && \
    mkdir -p /tmp/usr/ &&\
    ./configure --prefix=/tmp/usr/ --enable-utf8 && \
    touch cobj/*.m4 && \
    make && \
    make install && \
    rm -rf /root/opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz /root/opensourcecobol4j-${opensource_COBOL_4J_version}

# Runtime stage
FROM almalinux:9

SHELL ["/bin/bash", "-c"]

# install runtime dependencies only
RUN dnf update -y && \
    dnf install -y java-11-openjdk-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# copy built files from builder stage
COPY --from=builder /tmp/usr/ /usr/

# classpath settings
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar' >> ~/.bashrc

# add sample programs
ADD cobol_sample /root/cobol_sample

WORKDIR /root/

CMD ["/bin/bash"]
