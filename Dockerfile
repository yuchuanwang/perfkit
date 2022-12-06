# perfkit
# Run: docker run --privileged -v /lib/modules:/lib/modules:ro -v /usr/src:/usr/src:ro -v /sys/kernel/debug:/sys/kernel/debug:rw -v /etc/localtime:/etc/localtime:ro -it --pid=host perfkit bash

# Build Intermediate
ARG OS_IMAGE=ubuntu
ARG OS_VER=22.04
ARG DEBIAN_FRONTEND=noninteractive 
FROM ${OS_IMAGE}:${OS_VER} as Intermediate

# Download, build and install bcc to intermediate image
RUN apt-get update && \
    apt-get install -y python-is-python3 libclang-14-dev arping netperf iperf \
    checkinstall bison build-essential cmake flex git libedit-dev libllvm14 \
    llvm-14-dev zlib1g-dev libelf-dev libfl-dev python3-distutils wget
ARG BCC_VER=v0.25.0
ARG BCC_NAME=bcc-src-with-submodule.tar.gz
RUN wget https://kgithub.com/iovisor/bcc/releases/download/${BCC_VER}/${BCC_NAME} && \
    tar xf ${BCC_NAME} && \
    cd bcc && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr -DPYTHON_CMD=python3 .. && \
    make && \
    make install


# Build final image
ARG OS_IMAGE=ubuntu
ARG OS_VER=22.04
FROM ${OS_IMAGE}:${OS_VER}
LABEL Author="Yuchuan Wang, yuchuan.wang@gmail.com"

# Linux performance measurement and tuning tools: 
# perf, sar, vmstat, mpstat, pidstat, iostat, free, top, htop, 
# netstat, ethtool, ip, ss, nstat, nicstat, tcpdump, netperf, iperf, 
# turbostat, numactl, numastat, slabtop
RUN apt-get -y update && \
    apt-get install -y vim apt-utils pciutils psmisc linux-tools-common linux-tools-generic \
    strace sysstat htop pstack numactl net-tools iproute2 nicstat ethtool tcpdump arping netperf \
    iperf tcpreplay fatrace git python-is-python3 python3-distutils

# Flamegraph
ARG FLAME_REPO=https://github.com/brendangregg/FlameGraph.git
# Github is blocked by China GFW ridiculously
# so use this mirror instead in China for the case there is no ladder: 
ARG FLAME_REPO=https://kgithub.com/brendangregg/FlameGraph.git
RUN git clone --depth 1 ${FLAME_REPO}

# Copy files to final image
COPY README.md /
# Copy BCC tools to final image
COPY --from=Intermediate /usr/share/bcc/ /usr/share/bcc/
COPY --from=Intermediate /usr/lib/ /usr/lib/
COPY --from=Intermediate /usr/include/bcc/ /usr/include/bcc/

# Add BCC tools to PATH
ENV PATH="${PATH}:/usr/share/bcc/tools/"
