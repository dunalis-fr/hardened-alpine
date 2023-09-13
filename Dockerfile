FROM alpine:3.18.3 as base

# User management 
RUN adduser -D -s /bin/sh -u 1000 -H user
RUN sed -i -r '/^(user|root)/!d' /etc/group
RUN sed -i -r '/^(user|root)/!d' /etc/passwd
RUN sed -i -r '/^user:/! s#^(.*):[^:]*$#\1:/sbin/nologin#' /etc/passwd
RUN rm -rf /root

# Create /app folder
RUN mkdir /app
RUN chown user: /app

# Remove cron tasks
RUN rm -rf /var/spool/cron
RUN rm -rf /etc/crontabs
RUN rm -rf /etc/periodic

# Remove root dir 
RUN rm -rf /root

# Remove world-writable permissions 
RUN find / -xdev -type d -perm +0002 -exec chmod o-w {} +
RUN find / -xdev -type f -perm +0002 -exec chmod o-w {} +

# Remove dangerous programs and configs
RUN find $sysdirs -xdev \( \
  -name hexdump -o \
  -name chgrp -o \
  -name chmod -o \
  -name chown -o \
  -name ln -o \
  -name od -o \
  -name strings -o \
  -name su \
  -name ash \
  -name netstat \
  \) 

RUN find $sysdirs -xdev -regex '.*apk.*' -delete

# Remove init scripts since we do not use them.
RUN rm -fr /etc/init.d
RUN rm -fr /lib/rc
RUN rm -fr /etc/conf.d
RUN rm -fr /etc/inittab
RUN rm -fr /etc/runlevels
RUN rm -fr /etc/rc.conf

# Remove broken symlinks
RUN find $sysdirs -xdev -type l -exec test ! -e {} \; -delete


FROM scratch
COPY --from=base / /