FROM nginx:1.13.8

# fix www-data user to avoid permissions issues
RUN usermod -u 1000 nginx
RUN groupmod -g 1000 nginx

ADD default.conf /etc/nginx/conf.d/default.conf
ADD m1-hosts.conf /etc/nginx/conf.d/z-m1-hosts.conf
ADD m2-hosts.conf /etc/nginx/conf.d/z-m2-hosts.conf
ADD m-servers.conf /etc/nginx/conf.d/z-m-servers.conf
