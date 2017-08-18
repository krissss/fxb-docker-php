FROM daocloud.io/ubuntu:16.04

MAINTAINER kriss

# 切换 apt 镜像源
RUN ["sed", "-i", "s/archive.ubuntu.com/mirrors.163.com/g", "/etc/apt/sources.list"]

# 安装扩展和 nginx
RUN apt-get update && apt-get install -y \
		# PHP 及扩展
        php \
		# yii2 需要
		php-mbstring \
		php-gd \
		php-dom \
		php-intl \
		php-mysql \
		# 项目需要
		php-bcmath \
		php-zip \
		php-curl \
		# apache2
		apache2 \
		libapache2-mod-php \
		# supervisor
		supervisor \

	# 用完包管理器后安排打扫卫生可以显著的减少镜像大小
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#设置时区
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
  && echo 'Asia/Shanghai' >/etc/timezone

# PHP-FPM 环境设置
#RUN mkdir /run/php && touch /run/php/php7.0-fpm.sock

# PHP 配置
COPY ./php/ /etc/php/7.0/

# nginx 配置
COPY ./apache2/ /etc/apache2/

# supervisor 配置
COPY ./supervisor/ /etc/supervisor/

WORKDIR /app

# 主服务器设置1，从服务器设置0
ENV IS_MASTER_SERVER=1

# http 跳转到 https 端口
EXPOSE 79
# PC
EXPOSE 80
# PC admin
EXPOSE 81
# WX API
EXPOSE 82
# WX
EXPOSE 83

#CMD ["supervisord", "-c", "/etc/supervisor/${IS_MASTER_SERVER}/supervisord.conf", "-u", "root", "-n"]
CMD supervisord -c /etc/supervisor/${IS_MASTER_SERVER}/supervisord.conf -u root -n
