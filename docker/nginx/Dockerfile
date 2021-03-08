FROM nginx:1.19.6

# fix www-data user to avoid permissions issues
RUN usermod -u 1000 nginx
RUN groupmod -g 1000 nginx

ADD default.conf /etc/nginx/conf.d/default.conf
ADD m1-hosts.conf /etc/nginx/conf.d/z-m1-hosts.conf
ADD m2-hosts.conf /etc/nginx/conf.d/z-m2-hosts.conf
ADD m-servers.conf /etc/nginx/conf.d/z-m-servers.conf

# SSL
ADD certs/lemp.dm.crt /etc/ssl/certs/
ADD certs/lemp.dm.key /etc/ssl/private/

EXPOSE 443
