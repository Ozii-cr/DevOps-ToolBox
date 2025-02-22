# syntax = docker/dockerfile:1.2

# Stage 1: Build the application
FROM node:22.5.1-alpine3.20 AS builder

# Install pnpm
RUN npm install -g pnpm

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml to the working directory
COPY package.json pnpm-lock.yaml ./

# Install dependencies using pnpm
RUN pnpm install

# Copy the rest of the application code to the working directory
COPY . .

#remove env file
RUN rm ./.env 

# Build the Next.js application
RUN pnpm build

# Stage 2: Create the production image
FROM node:22.5.1-alpine3.20 AS runner

# Set environment variables for production
ENV NODE_ENV=production

# Set the working directory inside the container
WORKDIR /app


# You only need to copy next.config.js if you are NOT using the default configuration
COPY --from=builder /app/next.config.mjs ./
COPY --from=builder /app/public ./public

# Create a non-root user and group
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Set the correct permission for prerender cache
RUN mkdir .next
RUN chown nextjs:nodejs .next

# Automatically leverage output traces to reduce image size 
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 6000

ENV PORT 6000

#Disable telemetryy
ENV NEXT_TELEMETRY_DISABLED 1

# Start the Next.js application
CMD ["node", "server.js"]