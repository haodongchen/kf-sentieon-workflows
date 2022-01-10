FROM centos:8 as builder
RUN yum -y install git wget bzip2 python3 \
  && yum install -y epel-release \
  && yum install -y boost169-devel zlib-devel
RUN yum -y groupinstall 'Development Tools'

RUN mkdir -p /opt/bcftools/ && \
    curl -L https://github.com/samtools/bcftools/releases/download/1.14/bcftools-1.14.tar.bz2 | \
      tar -jxf - -C /opt/bcftools/ --no-same-owner && \
      cd /opt/bcftools/bcftools-1.14/ && \
      ./configure --disable-bz2 --disable-lzma && make && make install
RUN wget -O /usr/local/bin/bedtools https://github.com/arq5x/bedtools2/releases/download/v2.30.0/bedtools.static.binary \
    && chmod a+x /usr/local/bin/bedtools
RUN mkdir -p /opt/sentieon/ && \
    wget -nv -O - "https://s3.amazonaws.com/sentieon-release/software/sentieon-genomics-202112.tar.gz" | \
      tar -zxf - -C /opt/sentieon/
RUN mkdir -p /opt/dnascope_hifi/ && \
    wget -nv -O - "https://s3.amazonaws.com/sentieon-release/other/DNAscopeHiFiBeta0.4.pipeline.tar.gz" | \
      tar -zxf - -C /opt/dnascope_hifi/

FROM centos:8
RUN yum install -y which python3
RUN yum install -y epel-release
RUN yum install -y jemalloc
COPY --from=builder /opt/sentieon/sentieon-genomics-202112 /opt/sentieon/sentieon-genomics-202112
COPY --from=builder /usr/local/bin/* /usr/local/bin/
COPY --from=builder /usr/local/libexec/bcftools/* /usr/local/libexec/bcftools/
COPY --from=builder /opt/dnascope_hifi/DNAscopeHiFiBeta0.4.pipeline /opt/dnascope_hifi/DNAscopeHiFiBeta0.4.pipeline

ENV PATH /opt/sentieon/sentieon-genomics-202112/bin/:$PATH
ENV LD_PRELOAD /usr/lib64/libjemalloc.so.2
