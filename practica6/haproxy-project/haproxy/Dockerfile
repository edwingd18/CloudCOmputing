FROM haproxy:2.3
RUN mkdir -p /run/haproxy/
RUN mkdir -p /usr/local/etc/haproxy/errors/
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY errors/ /usr/local/etc/haproxy/errors/
