# Builder stage
FROM almalinux:9 AS builder

SHELL ["/bin/bash", "-c"]

# Install build dependencies
RUN dnf update -y && \
    dnf install -y gcc make bison flex automake autoconf diffutils gettext java-11-openjdk-devel gzip tar && \
    dnf clean all

# Install sbt
RUN curl -fL https://github.com/coursier/coursier/releases/latest/download/cs-x86_64-pc-linux.gz | gzip -d > cs && \
    chmod +x cs && \
    echo Y | ./cs setup

# Set PATH for sbt
ENV PATH="$PATH:/root/.local/share/coursier/bin"

# Build opensourcecobol4j with UTF-8 support
RUN cd /tmp && \
    curl -L -o opensourcecobol4j-v1.1.9.tar.gz https://github.com/opensourcecobol/opensourcecobol4j/archive/refs/tags/v1.1.9.tar.gz && \
    tar zxf opensourcecobol4j-v1.1.9.tar.gz && \
    cd opensourcecobol4j-1.1.9 && \
    ./configure --prefix=/usr/ --enable-utf8 && \
    touch cobj/*.m4 && \
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
# Copy JAR libraries
COPY --from=builder /usr/lib/opensourcecobol4j/ /usr/lib/opensourcecobol4j/
# Copy configuration and copy files
COPY --from=builder /usr/share/opensource-cobol-4j-1.1.9/ /usr/share/opensource-cobol-4j-1.1.9/
# Copy header file
COPY --from=builder /usr/include/libcobj.h /usr/include/

# Set classpath
ENV CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar
RUN echo 'export CLASSPATH=:/usr/lib/opensourcecobol4j/libcobj.jar' >> ~/.bashrc

# Add sample programs
ADD cobol_sample /root/cobol_sample

WORKDIR /root/

CMD ["/bin/bash"]

