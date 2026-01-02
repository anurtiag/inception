FROM nginx:bookworm


COPY ./conf /etc/nginx/conf.d
COPY ./conf/snippets/fastcgi-php.conf /etc/nginx/snippets/fastcgi-php.conf
COPY ./tools/entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]