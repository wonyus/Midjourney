# Stage 1: Builder
FROM node:21.7-alpine AS builder

# Update package repositories and install necessary build dependencies
RUN apt-get update && apt-get install -y \
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

# Copy the application source code to the builder stage
COPY . .

# Set NODE_ENV to 'production'
ENV NODE_ENV production

# Install npm dependencies
RUN npm ci

# Build the TypeScript application
RUN npm run build

# Stage 2: Runner
FROM node:21.7-alpine AS runner

# Set the working directory in the runner stage
WORKDIR /app

# Copy package.json and package-lock.json from builder stage
COPY --from=builder /app/package.json /app/package-lock.json ./

# Copy node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy TypeScript build from builder stage
COPY --from=builder /app/dist ./dist

# Define the command to run the application
CMD ["node", "dist/index.js"]
