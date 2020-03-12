FROM centos:7
MAINTAINER ThanhCL

RUN wget -P /etc/yum.repos.d https://copr.fedorainfracloud.org/coprs/czanik/syslog-ng324/repo/epel-7/czanik-syslog-ng325-epel-7.repo

#updated os, install some lib packages
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 && \
  yum clean all && \
  yum install -y epel-release && \
  yum install -y nginx python-pip syslog-ng telnet tcptraceroute mtr git patch libselinux-python libsemanage-python libselinux-python ntp unzip wget make mlocate gcc net-tools && \
  rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

#setup timezone
RUN echo "ZONE=\"Asia/Ho_Chi_Minh\"" > /etc/sysconfig/clock && \
  rm -rf /etc/localtime && \
  ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

RUN pip install syslogng_kafka

ADD kafka.conf /etc/syslog-ng/conf.d/kafka.conf
ADD index.html /usr/share/nginx/html/index.html

EXPOSE 80/tcp
EXPOSE 514/udp

ENTRYPOINT ["/usr/sbin/syslog-ng", "-F"]
CMD ["nginx", "-g daemon off;"]
