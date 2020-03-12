FROM centos:7
MAINTAINER ThanhCL

#updated os, install some lib packages
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 && \
  yum clean all && \
  yum install -y epel-release && \
  yum install -y librdkafka-devel nginx python python-requests python-pip python-devel telnet tcptraceroute mtr git patch libselinux-python libsemanage-python libselinux-python ntp unzip wget make mlocate gcc net-tools && \
  rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

#setup timezone
RUN echo "ZONE=\"Asia/Ho_Chi_Minh\"" > /etc/sysconfig/clock && \
  rm -rf /etc/localtime && \
  ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

RUN wget -P /etc/yum.repos.d https://copr.fedorainfracloud.org/coprs/czanik/syslog-ng324/repo/epel-7/czanik-syslog-ng325-epel-7.repo
RUN yum install -y syslog-ng 

RUN pip install syslogng_kafka

ADD kafka.conf /etc/syslog-ng/conf.d/kafka.conf
ADD syslog-ng.conf /etc/syslog-ng/syslog-ng.conf
ADD index.html /usr/share/nginx/html/index.html

EXPOSE 80/tcp
EXPOSE 514/udp


# Forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log


STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/sbin/syslog-ng", "-F"]
CMD ["nginx", "-g", "daemon off;"]

