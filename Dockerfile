 FROM swiftlang/swift:nightly-amazonlinux2
 RUN yum -y install git \
 libuuid-devel \
 libicu-devel \
 libedit-devel \
 libxml2-devel \
 sqlite-devel \
 python-devel \
 ncurses-devel \
 curl-devel \
 openssl-devel \
 tzdata \
 libtool \
 jq \
 tar \
 zip \
 libssl-dev \
 zlib1g-dev \
 gd \
 gd-devel \
 php-devel \
 fpc-src
