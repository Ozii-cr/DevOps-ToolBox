## Overview

This Dockerfile creates a production-ready Docker image for a Next.js application. It uses a multi-stage build process to optimize the final image size and security.

## Important Notes

1. **Base Image Version**: The Dockerfile uses `node:22.5.1-alpine3.20`. You can change this version to suit your needs by modifying the `FROM` statements in both build stages.

2. **Port Configuration**: The default port is set to 6000. You can change this by modifying the `EXPOSE` and `ENV PORT` instructions in the Dockerfile.

3. **Package Manager**: This Dockerfile is configured for pnpm. If your project uses a different package manager (npm or yarn), replace `pnpm-lock.yaml` with the appropriate lock file and adjust the install commands accordingly.

4. **Next.js Configuration**: This Dockerfile requires a specific Next.js configuration to work correctly. In your `next.config.mjs` file, ensure you have the following configuration:

   ```javascript
   const nextConfig = {
     output: 'standalone',
     // ... other configurations
   };
   ```

   Without the `output: 'standalone'` option, this Docker setup will not function properly.

## Dockerfile Structure

The Dockerfile consists of two stages:

1. **Builder Stage**: Builds the Next.js application
2. **Runner Stage**: Creates the final production image

## Prerequisites

- Docker installed on your system
- A Next.js project with `package.json` and the appropriate lock file
- `next.config.mjs` configured with `output: 'standalone'`

## Build Process

### Builder Stage

- Uses `node:22.5.1-alpine3.20` as the base image (version can be changed)
- Installs pnpm globally (change this if using a different package manager)
- Copies project files and installs dependencies
- Builds the Next.js application
- Removes the `.env` file for security

### Runner Stage

- Uses `node:22.5.1-alpine3.20` as the base image (version can be changed)
- Sets up the production environment
- Copies necessary files from the builder stage
- Creates a non-root user for security
- Sets up permissions for the Next.js application

## Key Features

- Uses pnpm for faster, more efficient package management (can be changed to npm or yarn)
- Multi-stage build for a smaller final image
- Runs the application as a non-root user
- Optimized for production use
- Disables Next.js telemetry

## Usage

1. Ensure your `next.config.mjs` includes `output: 'standalone'`.
2. Adjust the Dockerfile if you're not using pnpm (replace pnpm commands and lock file references).
3. Place this Dockerfile in your Next.js project root.
4. Build the Docker image:
   ```
   docker build -t my-nextjs-app .
   ```
5. Run the container:
   ```
   docker run -p 6000:6000 my-nextjs-app
   ```

The application will be available at `http://localhost:6000` (or the port you configured).

## Environment Variables

- `NODE_ENV`: Set to `production`
- `PORT`: Set to `6000` (can be changed in the Dockerfile)
- `NEXT_TELEMETRY_DISABLED`: Set to `1` to disable telemetry

## Custom Configuration

- The `next.config.mjs` file is copied if you're using a custom Next.js configuration.
- The `.env` file is deliberately removed during the build process for security reasons. Handle environment variables through Docker or your deployment platform.

## Security Notes

- The application runs as a non-root user (`nextjs`) for enhanced security.
- Ensure sensitive data is not baked into the image. Use runtime environment variables for secrets.

## Optimization

- The build process uses output traces to reduce the final image size.
- Static files are properly handled for efficient serving.

## Customization

To customize the build process:
- Modify the Node.js or Alpine versions in the `FROM` statements as needed.
- Adjust the exposed port (default is 6000) if necessary.
- Change the package manager commands if not using pnpm.
- Add additional build steps or environment setup as required by your project.

## Troubleshooting

If you encounter issues:
- Ensure all necessary files are in the correct locations in your project.
- Verify that your `package.json` is correctly configured for a Next.js project.
- Check that your `next.config.mjs` includes `output: 'standalone'`.
- Confirm you're using the correct package manager commands and lock file.
- Check Docker logs for any error messages during build or runtime.