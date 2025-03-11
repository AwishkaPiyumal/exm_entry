import { NextResponse } from "next/server";
import { jwtVerify } from "jose";

export async function middleware(req) {
  const pathname = req.nextUrl.pathname;

  // Bypass middleware for static files and API routes
  if (
    pathname.startsWith("/_next") || // Internal assets
    pathname.startsWith("/static") || // Custom static files
    pathname.startsWith("/api") // API routes
  ) {
    return NextResponse.next();
  }

  // Allow public routes
  const publicRoutes = ["/", "/reset-password"];
  if (publicRoutes.some((route) => pathname === route)) {
    return NextResponse.next();
  }

  // Check for token in cookies
  const token = req.cookies.get("access-token")?.value;

  // If no token, redirect to login
  if (!token) {
    return NextResponse.redirect(new URL("/", req.url));
  }

  try {
    // Verify JWT token
    const secretKey = new TextEncoder().encode(
      process.env.NEXT_PUBLIC_JWT_SECRET
    );
    const { payload: user } = await jwtVerify(token, secretKey);

    if (!user) {
      return NextResponse.redirect(new URL("/", req.url));
    }

    //Allow everyone to the Home apge
    if (pathname == `/home`) {
      return NextResponse.next();
    }

    //check if the user is student and he visiting a allowed page
    const stuAllowedPages = ["home/form"];
    const isStuAllowedPage = stuAllowedPages.some((page) =>
      pathname.startsWith(`/${page}`)
    );

    if (user.role_id === "5") {
      if (isStuAllowedPage) {
        return NextResponse.next();
      } else {
        return NextResponse.redirect(new URL("/home", req.url));
      }
    }

    //check if the user is lecturer and he visiting a allowed page
    const lecAllowedPages = ["home/subjects"];
    const isLecAllowedPage = lecAllowedPages.some((page) =>
      pathname.startsWith(`/${page}`)
    );

    if (user.role_id === "4") {
      if (isLecAllowedPage) {
        return NextResponse.next();
      } else {
        return NextResponse.redirect(new URL("/home", req.url));
      }
    }

    //check if the user is lecturer and he visiting a allowed page
    const deanHodAllowedPages = ["home/batches", "report"];
    const isdeanHodAllowedPage = deanHodAllowedPages.some((page) =>
      pathname.startsWith(`/${page}`)
    );

    if (user.role_id === "2" || user.role_id === "3") {
      if (isdeanHodAllowedPage) {
        return NextResponse.next();
      } else {
        return NextResponse.redirect(new URL("/home", req.url));
      }
    }

    // Check if the user has access to certain pages
    const restrictedPages = ["examinations", "courses", "entries", "users"];
    const isRestrictedPage = restrictedPages.some((page) =>
      pathname.startsWith(`/${page}`)
    );
    if (isRestrictedPage && user.role_id !== "1") {
      // Only allow admins (role_id 1)
      return NextResponse.redirect(new URL("/home", req.url));
    }

    // Proceed with the request if all checks pass
    return NextResponse.next();
  } catch (error) {
    console.error("JWT verification failed:", error);
    return NextResponse.redirect(new URL("/", req.url)); // Redirect to login on error
  }
}
