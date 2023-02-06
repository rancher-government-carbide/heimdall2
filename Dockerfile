ARG BASE_CONTAINER=node:16-alpine

FROM $BASE_CONTAINER as builder

ARG YARNREPO_MIRROR=https://registry.yarnpkg.com
ENV YARNREPO=$YARNREPO_MIRROR

WORKDIR /src
USER 0

COPY package.json yarn.lock lerna.json tsconfig.json .prettierrc ./
# COPY apps ./apps
# COPY libs ./libs

COPY apps/frontend/package.json ./apps/frontend/package.json
COPY apps/backend/package.json ./apps/backend/package.json
COPY libs/hdf-converters/package.json ./libs/hdf-converters/package.json
COPY libs/inspecjs/package.json ./libs/inspecjs/package.json
COPY libs/interfaces/package.json ./libs/interfaces/package.json
COPY libs/password-complexity/package.json ./libs/password-complexity/package.json

RUN chmod 0500 -R apps libs
RUN apk add python3 make g++
RUN sed -i s^https://registry.yarnpkg.com^$YARNREPO^g yarn.lock
RUN yarn --frozen-lockfile --production --network-timeout 600000

COPY --chown=node apps ./apps
COPY --chown=node libs ./libs

RUN yarn run build
# RUN chown -R node apps libs package.json
RUN chmod 0400 package.json libs/interfaces/package.json tsconfig.json .prettierrc
RUN chmod 0500 -R apps libs

### Production image

FROM $BASE_CONTAINER as app

WORKDIR /app

COPY package.json ./
COPY --chown=node --from=builder /src/apps/backend/package.json apps/backend/
COPY --chown=node --from=builder /src/apps/frontend/package.json apps/frontend/
COPY --chown=node --from=builder /src/libs/interfaces/package.json libs/interfaces/
COPY --chown=node --from=builder /src/libs/password-complexity/ libs/password-complexity/
COPY --chown=node --from=builder /src/apps/backend/node_modules apps/backend/node_modules
COPY --chown=node --from=builder /src/apps/backend/dist apps/backend/dist
COPY --chown=node --from=builder /src/dist/ dist/
COPY --chown=node --from=builder /src/apps/backend/.sequelizerc /app/apps/backend/
COPY --chown=node --from=builder /src/apps/backend/db /app/apps/backend/db
COPY --chown=node --from=builder /src/apps/backend/config /app/apps/backend/config
COPY --chown=node --from=builder /src/apps/backend/migrations /app/apps/backend/migrations
COPY --chown=node --from=builder /src/apps/backend/seeders /app/apps/backend/seeders
RUN chown -R node /app
# RUN chown node package.json libs libs/interfaces libs/interfaces/package.json libs/password-complexity apps/backend/node_modules apps/backend/seeders apps/backend/config apps/backend/db apps/backend/migrations apps/backend/seeders apps/backend/package.json apps/backend apps/frontend apps/frontend/package.json
# RUN chown node dist/frontend/js dist/frontend/js/* dist/frontend dist/frontend/*
RUN chmod 0400 libs/interfaces/package.json apps/frontend/package.json


EXPOSE 3000

COPY cmd.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/cmd.sh

USER node

CMD ["/usr/local/bin/cmd.sh"]
