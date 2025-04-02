/** @type {import('next').NextConfig} */

const server = process.env.BACKEND_SERVER;
const port = process.env.BACKEND_PORT;

const nextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/:path*", // When frontend calls "/api/..."
        destination: `http://${server}:${port}/api1/:path*`, // Forward request to backend
      },
    ];
  },
};

export default nextConfig;
