/** @type {import('next').NextConfig} */

const server = process.env.BACKEND_SERVER;

const nextConfig = {
  async rewrites() {
    return [
      {
        source: "/api/:path*", // When frontend calls "/api/..."
        destination: `${server}/api1/:path*`, // Forward request to backend without port
      },
    ];
  },
};
export default nextConfig;
