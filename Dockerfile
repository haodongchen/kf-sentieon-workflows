FROM ubuntu:22.04 AS builder

ARG SENTIEON_VERSION
RUN test -n "$SENTIEON_VERSION"

LABEL container.base.image="ubuntu:22.04" \
      software.version="${SENTIEON_VERSION}" \
      software.website="https://www.sentieon.com/" \
      maintainer="Haodong Chen (haodong.chen@sentieon.com)"

# Install igzip
RUN apt update -y && apt install -y gzip autoconf libtool binutils make nasm curl && \
    mkdir -p /opt/isa-l && \
    curl -L "https://github.com/intel/isa-l/archive/refs/tags/v2.30.0.tar.gz" | \
        tar -C /opt/isa-l -zxf - && \
    cd /opt/isa-l/isa-l-2.30.0 && \
    ./autogen.sh && \
    ./configure --prefix=/usr --libdir=/usr/lib && \
    make install

# Install samtools
RUN apt update -y && apt install -y autoconf automake make gcc perl bzip2 zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev libdeflate-dev tar curl && \
    mkdir -p /opt/samtools/ && \
    curl -L "https://github.com/samtools/samtools/releases/download/1.16.1/samtools-1.16.1.tar.bz2" | \
      tar -C /opt/samtools/ -jxf - && \
    cd /opt/samtools/samtools-1.16.1 && \
    ./configure && \
    make install

# Install bcftools
RUN apt update -y && apt install -y autoconf automake make gcc perl bzip2 zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libperl-dev libgsl0-dev tar curl && \
    mkdir -p /opt/bcftools/ && \
    curl -L "https://github.com/samtools/bcftools/releases/download/1.16/bcftools-1.16.tar.bz2" | \
      tar -C /opt/bcftools/ -jxf - && \
    cd /opt/bcftools/bcftools-1.16/ && \
    ./configure && \
    make install

# Install bedtools
RUN apt update -y && apt install -y curl && \
    curl -L -o /usr/local/bin/bedtools-2.30.0 "https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary"

# Install sentieon
RUN apt update -y && apt install -y curl tar && \
    mkdir -p /opt/sentieon/ && \
    curl -L "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-${SENTIEON_VERSION}.tar.gz" | \
      tar -C /opt/sentieon -zxf -

# Build the container
FROM ubuntu:22.04
ARG SENTIEON_VERSION
ENV SENTIEON_VERSION=$SENTIEON_VERSION

# Copy dependencies from the first stage
COPY --from=builder /opt/sentieon/sentieon-genomics-${SENTIEON_VERSION} /opt/sentieon/sentieon-genomics-${SENTIEON_VERSION}
COPY --from=builder /usr/bin/igzip /usr/bin/igzip
COPY --from=builder /usr/lib/libisal.a /usr/lib/libisal.a
COPY --from=builder /usr/lib/libisal.so.2.0.30 /usr/lib/libisal.so.2.0.30
COPY --from=builder /usr/lib/libisal.la /usr/lib/libisal.la
COPY --from=builder /usr/local/bin/samtools /usr/local/bin/samtools
COPY --from=builder /usr/local/bin/bcftools /usr/local/bin/bcftools
COPY --from=builder /usr/local/bin/bedtools-2.30.0 /usr/local/bin/bedtools-2.30.0

ENV SENTIEON_INSTALL_DIR=/opt/sentieon/sentieon-genomics-${SENTIEON_VERSION}
ENV PATH $SENTIEON_INSTALL_DIR/bin:$PATH
# Install dependencies
RUN apt update -y && apt install -y libjemalloc2 python3 zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libncurses5-dev libdeflate-dev
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
# A default jemalloc configuration that should work well for most use-cases, see http://jemalloc.net/jemalloc.3.html
ENV MALLOC_CONF=metadata_thp:auto,background_thread:true,dirty_decay_ms:30000,muzzy_decay_ms:30000

# Create links
RUN cd /usr/local/bin/ && \
    ln -s bedtools-2.30.0 bedtools && \
    chmod ugo+x bedtools-2.30.0

RUN cd /usr/lib && ls -lah && \
    ln -s libisal.so.2 libisal.so

# Test the container
RUN sentieon driver --help && \
    igzip --help && \
    samtools --help && \
    bcftools --help && \
    bedtools --help

CMD ["/bin/bash"]
