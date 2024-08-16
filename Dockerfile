FROM openresty/openresty

WORKDIR /app

RUN mkdir -p ./logs
RUN touch ./logs/error.log

COPY ./conf ./conf/
COPY ./site ./site/
COPY ./docker-entrypoint.sh ./docker-entrypoint.sh

EXPOSE 8080

ENTRYPOINT [ "bash" ]
CMD [ "docker-entrypoint.sh" ]
