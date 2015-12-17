FROM ubuntu:14.04
MAINTAINER nrshrivatsan@outlook.com

RUN apt-get update \
      && apt-get -y install software-properties-common

RUN add-apt-repository ppa:openjdk-r/ppa -y
RUN apt-get update && apt-get -y install \
      bison \
      curl \
      wget \
      git \
      libapr1-dev \
      libcurl4-nss-dev \
      libsasl2-dev \
      libsvn-dev \
      openjdk-8-jdk \
      openssh-server \
      python-dev \
      zookeeperd

# Ensure java 8 is the default java.
RUN update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java

# Docker
#RUN wget -qO- https://get.docker.com/ | sh

# Aurora
RUN git clone git://git.apache.org/aurora.git /aurora
ENV MESOS_VERSION 0.25.0
RUN mkdir -p /aurora/third_party
ADD https://svn.apache.org/repos/asf/aurora/3rdparty/ubuntu/trusty64/python/mesos.native-0.25.0-py2.7-linux-x86_64.egg /aurora/third_party/

ADD http://people.apache.org/~jfarrell/thrift/0.9.1/contrib/deb/ubuntu/12.04/thrift-compiler_0.9.1_amd64.deb /
ADD http://downloads.mesosphere.io/master/ubuntu/14.04/mesos_0.25.0-0.2.70.ubuntu1404_amd64.deb /
RUN dpkg --install thrift-compiler_0.9.1_amd64.deb
RUN dpkg --install mesos_0.25.0-0.2.70.ubuntu1404_amd64.deb

# sshd
RUN mkdir -p /var/run/sshd
RUN sed -i 's/^PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN sed -i 's/.*session.*required.*pam_loginuid.so.*/session optional pam_loginuid.so/g' /etc/pam.d/sshd

# build aurora
ADD _aurorabuild.sh /aurora/
RUN cd /aurora && bash ./_aurorabuild.sh
RUN mkdir -p /etc/aurora

# init script
ADD init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

CMD ["/usr/local/bin/init.sh"]

#docker build -t cmaz .
#docker run -it -p 8081:8081 -p 5050:5050 -p 2181:2181 -p 2888:2888 -p 3888:3888 cmaz
