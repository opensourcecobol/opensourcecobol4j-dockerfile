# Builder stage
FROM almalinux:9 AS builder

SHELL ["/bin/bash", "-c"]

# Install build dependencies
RUN dnf update -y && \
    dnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel curl gzip tar && \
    dnf clean all

# Install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && \
    chmod +x cs && \
    echo Y | ./cs setup

# Set PATH for sbt
ENV PATH="$PATH:/root/.local/share/coursier/bin"

# Build opensourcecobol4j
RUN cd /tmp && \
    curl -L -o opensourcecobol4j-v1.1.9.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.1.9.tar.gz && \
    tar zxf opensourcecobol4j-v1.1.9.tar.gz && \
    cd opensourcecobol4j-1.1.9 && \
    ./configure --prefix=/usr/ && \
    make && \
    make install

# Build Open COBOL ESQL 4J
RUN mkdir -p /usr/lib/Open-COBOL-ESQL-4j && \
    cd /tmp && \
    curl -L -o Open-COBOL-ESQL-4j-1.1.1.tar.gz https://github.com/opensourcecobol/Open-COBOL-ESQL-4j/archive/refs/tags/v1.1.1.tar.gz && \
    tar zxf Open-COBOL-ESQL-4j-1.1.1.tar.gz && \
    cd Open-COBOL-ESQL-4j-1.1.1 && \
    curl -L -o /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar https://jdbc.postgresql.org/download/postgresql-42.2.24.jar && \
    cp /usr/lib/opensourcecobol4j/libcobj.jar dblibj/lib && \
    cp /usr/lib/Open-COBOL-ESQL-4j/postgresql.jar dblibj/lib && \
    ./configure --prefix=/usr/ && \
    make && \
    make install

# Runtime stage
FROM almalinux:9

SHELL ["/bin/bash", "-c"]

# Install only runtime dependencies
RUN dnf update -y && \
    dnf install -y java-11-openjdk-headless && \
    dnf clean all

# Copy installed files from builder
# Copy opensourcecobol4j executables
COPY --from=builder /usr/bin/cobj /usr/bin/
COPY --from=builder /usr/bin/cobjrun /usr/bin/
COPY --from=builder /usr/bin/cob-config /usr/bin/
COPY --from=builder /usr/bin/cobj-idx /usr/bin/
COPY --from=builder /usr/bin/cobj-api /usr/bin/
# Copy Open COBOL ESQL 4J executable
COPY --from=builder /usr/bin/ocesql4j /usr/bin/
# Copy JAR libraries
COPY --from=builder /usr/lib/opensourcecobol4j/ /usr/lib/opensourcecobol4j/
COPY --from=builder /usr/lib/Open-COBOL-ESQL-4j/ /usr/lib/Open-COBOL-ESQL-4j/
# Copy configuration and copy files
COPY --from=builder /usr/share/opensource-cobol-4j-1.1.9/ /usr/share/opensource-cobol-4j-1.1.9/
# Copy header file
COPY --from=builder /usr/include/libcobj.h /usr/include/

# Set classpath
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar:/usr/lib/Open-COBOL-ESQL-4j/postgresql.jar:/usr/lib/Open-COBOL-ESQL-4j/ocesql4j.jar' >> ~/.bashrc

# Add sample programs
ADD cobol_sample /root/cobol_sample
ADD ocesql4j_sample /root/ocesql4j_sample

WORKDIR /root/

CMD ["/bin/bash"]