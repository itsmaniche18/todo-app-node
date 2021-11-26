FROM ubuntu AS build
ENV NODE_VERSION=12.13.0
RUN apt-get update && apt-get install -y curl
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node -v && npm -v
WORKDIR /app
COPY . .
RUN npm install -g yarn
RUN yarn install --production

FROM node:12-alpine
WORKDIR /app
COPY --from=build /app/src/ ./src
COPY --from=build /app/spec ./spec
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json /app/yarn.lock ./
EXPOSE 3000
CMD ["node", "src/index.js"]