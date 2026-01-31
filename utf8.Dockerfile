# Build stage
FROM almalinux:9-minimal AS builder

ARG opensource_COBOL_4J_version=dummy_value

SHELL ["/bin/bash", "-c"]

# install build dependencies
RUN microdnf update -y && \
    microdnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel tar gzip && \
    microdnf clean all

# install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && \
    chmod +x cs && \
    echo Y | ./cs setup

# build opensourcecobol4j
RUN cd /root && \
    curl -L -o opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v${opensource_COBOL_4J_version}.tar.gz && \
    tar zxvf opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz && \
    cd opensourcecobol4j-${opensource_COBOL_4J_version} && \
    ./configure --prefix=/usr/ --enable-utf8 && \
    touch cobj/*.m4 && \
    make && \
    make install && \
    rm -rf /root/opensourcecobol4j-v${opensource_COBOL_4J_version}.tar.gz /root/opensourcecobol4j-${opensource_COBOL_4J_version}

# Download postgresql jar
RUN mkdir -p /usr/lib/Open-COBOL-ESQL-4j/ && \
    curl -L -o /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jar

# Build Open COBOL ESQL 4J
ENV PATH="$PATH:/root/.local/share/coursier/bin"
RUN cd /root/ && \
    curl -L -o Open-COBOL-ESQL-4j-${Open_COBOL_ESQL_4J_version}.tar.gz https://github.com/opensourcecobol/Open-COBOL-ESQL-4j/archive/refs/tags/v${Open_COBOL_ESQL_4J_version}.tar.gz && \
    tar zxvf Open-COBOL-ESQL-4j-${Open_COBOL_ESQL_4J_version}.tar.gz && \
    cd Open-COBOL-ESQL-4j-${Open_COBOL_ESQL_4J_version} && \
    cp /usr/lib/opensourcecobol4j/libcobj.jar dblibj/lib && \
    cp /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar dblibj/lib && \
    ./configure --prefix=/usr/ --enable-utf8 && \
    make && \
    make install && \
    rm -rf /root/Open-COBOL-ESQL-4j-${Open_COBOL_ESQL_4J_version}.tar.gz /root/Open-COBOL-ESQL-4j-${Open_COBOL_ESQL_4J_version}

# Runtime stage
FROM almalinux:9-minimal

ARG opensource_COBOL_4J_version=dummy_value Open_COBOL_ESQL_4J_version=dummy_value

SHELL ["/bin/bash", "-c"]

# install runtime dependencies only
RUN microdnf update -y && \
    microdnf install -y java-11-openjdk-devel && \
    microdnf clean all && \
    rm -rf /var/cache/microdnf/*

# create required directories
RUN mkdir -p /usr/lib/opensourcecobol4j \
             /usr/lib/Open-COBOL-ESQL-4j \
             /usr/bin/ \
             /usr/include/ \
             /usr/lib/share

# copy built files from builder stage
COPY --from=builder /usr/lib/opensourcecobol4j/ /usr/lib/opensourcecobol4j/
COPY --from=builder /usr/lib/Open-COBOL-ESQL-4j/ /usr/lib/Open-COBOL-ESQL-4j/
COPY --from=builder /usr/bin/cob-config /usr/bin/cob-config
COPY --from=builder /usr/bin/cobj /usr/bin/cobj
COPY --from=builder /usr/bin/cobj-api /usr/bin/cobj-api
COPY --from=builder /usr/bin/cobj-idx /usr/bin/cobj-idx
COPY --from=builder /usr/bin/cobjrun /usr/bin/cobjrun
COPY --from=builder /usr/bin/ocesql /usr/bin/ocesql
COPY --from=builder /usr/include/libcobj.h /usr/include/libcobj.h
COPY --from=builder /usr/share/opensource-cobol-4j-${opensource_COBOL_4J_version} /usr/share/opensource-cobol-4j-${opensource_COBOL_4J_version}

# classpath settings
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar' >> ~/.bashrc

# add sample programs
ADD cobol_sample /root/cobol_sample
ADD ocesql4j_sample /root/ocesql4j_sample

WORKDIR /root/

CMD ["/bin/bash"]
