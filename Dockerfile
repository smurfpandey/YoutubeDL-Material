FROM arm32v7/node:12.18.4-alpine3.12 as frontend

RUN npm install -g @angular/cli

WORKDIR /build
COPY [ "package.json", "package-lock.json", "/build/" ]
RUN npm install

COPY [ "angular.json", "tsconfig.json", "/build/" ]
COPY [ "src/", "/build/src/" ]
RUN ng build --prod

#--------------#

FROM arm32v7/node:12.18.4-alpine3.12

RUN apk add --no-cache \
  ffmpeg \
  python2 \
  su-exec \
  && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    atomicparsley

WORKDIR /app
COPY [ "backend/package.json", "backend/package-lock.json", "/app/" ]
RUN npm install

COPY --from=frontend [ "/build/backend/public/", "/app/public/" ]
COPY [ "/backend/", "/app/" ]

EXPOSE 17442
ENTRYPOINT [ "/app/entrypoint.sh" ]
CMD [ "node", "app.js" ]
