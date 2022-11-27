from fedora:36

RUN yum install -y yosys python3-pip && \
    pip3 install click && \
    yum clean all && \
    rm -rf /var/cache/yum
