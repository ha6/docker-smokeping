FROM ubuntu:xenial

MAINTAINER Smokeping "babyfenei@qq.com"

ENV SMOKEPING_VERSION 2.6.11-2
ENV ZONE=Asia/Shanghai
VOLUME ["/etc/smokeping/config.d/"]

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
      smokeping=${SMOKEPING_VERSION} \
      nginx \
      apache2-utils \
      fonts-wqy-zenhei \
      fcgiwrap \
      less \
      openssh-client \
      curl \
      vim \
      fping \
      echoping \
      dnsutils \
      sendmail && \
    rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

ADD ./conf/smokeping /etc/nginx/sites-available/smokeping
ADD ./conf/vimrc /etc/vim/
ADD ./conf/config.d/ /etc/smokeping/config.d/
ADD ./start.sh /start.sh

RUN sed -i 's/^DAEMON_USER=smokeping/DAEMON_USER=www-data/g' /etc/init.d/smokeping && \
    chown www-data.www-data /etc/smokeping/smokeping_secrets && \
    chown -R www-data.www-data /var/lib/smokeping/ && \
    ln -s /usr/share/doc/fcgiwrap/examples/nginx.conf /etc/nginx/fcgiwrap.conf && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /usr/share/smokeping/www/smokeping.cgi && \
    ln -s /usr/share/smokeping/www /usr/share/smokeping/www/smokeping && \
    rm -f /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/smokeping /etc/nginx/sites-enabled/smokeping && \
    htpasswd -bc /etc/nginx/pass_file admin admin@123

EXPOSE 80 443

CMD ["/bin/sh","/start.sh"]
