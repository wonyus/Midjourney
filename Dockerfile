# Stage 1: Builder
FROM node:21.7-alpine AS builder

RUN apk add --no-cache \
    python \
    g++ \
    build-base \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    musl-dev \
    giflib-dev \
    pixman-dev \
    pangomm-dev \
    libjpeg-turbo-dev \
    freetype-dev

# Set the working directory in the builder stage
WORKDIR /app

# Copy the rest of your application source code to the builder stage
COPY . .

# Set NODE_ENV to 'production'
ENV NODE_ENV production

RUN npm i

# Build the TypeScript application in the builder stage
RUN npm run build

# Stage 3: Runner
FROM node:21.7-alpine AS runner

# Set the working directory in the runner stage
WORKDIR /app

COPY --from=builder /app/package.json /app/package-lock.json ./

COPY --from=builder /app/node_modules ./node_modules

# # Copy the TypeScript build from the builder stage
COPY --from=builder /app/dist ./dist


# Define the command to run your application in the runner stage
CMD ["node", "dist/index.js"]
