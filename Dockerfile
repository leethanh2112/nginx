FROM centos:centos7
MAINTAINER ThanhCL

ENV container docker
ENV container=docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME /run /tmp
CMD /usr/sbin/init

#updated os, install some lib packages
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 && \
  rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 && \
  yum clean all && \
  yum install -y epel-release && \
  yum install -y git patch libselinux-python libsemanage-python libselinux-python ntp unzip wget make mlocate gcc net-tools && \
  rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

#setup timezone
RUN echo "ZONE=\"Asia/Ho_Chi_Minh\"" > /etc/sysconfig/clock && \
  rm -rf /etc/localtime && \
  ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

RUN systemctl stop firewalld


RUN yum install -y ansible


COPY ./ansible /srv/ansible-nginx
COPY ./ansible/config/ansible.cfg /etc/ansible/ansible.cfg

RUN /bin/bash -c 'ansible-playbook -i /srv/ansible-nginx/host /srv/ansible-nginx/nginx.yml'

WORKDIR /var/www/html

EXPOSE 80 443






