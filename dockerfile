# Base stage
FROM node:22.16.0

WORKDIR /web

COPY ./package*.json ./
COPY ./tsconfig*.json ./

RUN npm install -g npm 
RUN npm install

COPY . .

RUN npm run build

#Build stage
FROM node:22.16.0-alpine AS base 

WORKDIR /web

COPY ./package*.json ./
COPY ./tsconfig*.json ./

FROM base AS build

RUN npm install -g npm
RUN npm install

COPY . .

RUN npx prisma generate
RUN npm run build
RUN npm prune --prod 

FROM base AS deploy

# Production stage
COPY --from=build /web/.next /web/.next
COPY --from=build /web/public /web/public
COPY --from=build /web/node_modules /web/node_modules
COPY --from=build /web/package.json /web/package.json

EXPOSE 3000
CMD ["npm", "start"]
