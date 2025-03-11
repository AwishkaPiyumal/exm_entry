"use client";
import { usePathname } from "next/navigation";
import React from "react";
import {
  Breadcrumb,
  BreadcrumbItem,
  BreadcrumbLink,
  BreadcrumbList,
  BreadcrumbPage,
  BreadcrumbSeparator,
} from "@/components/ui/breadcrumb";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { useUser } from "@/utils/useUser";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Button } from "./ui/button";
import user_avatar from "./../images/user_avatar.jpg";
import Link from "next/link";
import { FaKey } from "react-icons/fa6";
const regex = /^[a-zA-Z]+\d+$/;

const DashboardHeader = ({ logoutHandler }) => {
  const pathname = usePathname().split("/").slice(1);
  const { data: user, isLoading, error } = useUser();

  if (error) return (window.location.href = "/");

  return (
    <div className="fixed top-14 sm:top-16 md:top-18 lg:top-20 z-50 w-full border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 h-12 shadow flex justify-end sm:justify-between px-2 sm:px-5  items-center text-sm md:text-base">
      <Breadcrumb className="hidden sm:inline-block">
        <BreadcrumbList>
          {pathname.map((item, ind) => {
            if (ind !== pathname.length - 1) {
              return (
                <React.Fragment key={ind}>
                  <BreadcrumbItem>
                    <span
                      className={`${
                        regex.test(decodeURI(item)) ? "uppercase" : "capitalize"
                      } `}
                    >
                      {decodeURI(item)}
                    </span>
                  </BreadcrumbItem>
                  <BreadcrumbSeparator />
                </React.Fragment>
              );
            } else {
              return (
                <BreadcrumbItem key={ind}>
                  <BreadcrumbPage>
                    <span
                      className={`${
                        regex.test(decodeURI(item)) ? "uppercase" : "capitalize"
                      } font-semibold `}
                    >
                      {decodeURI(item)}
                    </span>
                  </BreadcrumbPage>
                </BreadcrumbItem>
              );
            }
          })}
        </BreadcrumbList>
      </Breadcrumb>
      <Popover>
        <PopoverTrigger>
          <div className="flex items-center gap-3">
            <h1 className="capitalize">{user?.name || user?.user_name}</h1>
            <Avatar className="flex justify-center items-center">
              <AvatarImage src={user_avatar.src} className="size-[34px]" />
              <AvatarFallback>
                <span className="inline-block capitalize">
                  {user?.name?.slice(0, 2) || user?.user_name?.slice(0, 2)}
                </span>
              </AvatarFallback>
            </Avatar>
          </div>
        </PopoverTrigger>
        <PopoverContent className="w-48">
          <Link
            href="/change password"
            className="text-sm flex items-center border-y border-zinc-200 py-3"
          >
            Change password&nbsp;&nbsp;&nbsp;&nbsp;
            <FaKey />
          </Link>
          <Button className="mt-6" variant="outline" onClick={logoutHandler}>
            Logout
          </Button>
        </PopoverContent>
      </Popover>
    </div>
  );
};

export default DashboardHeader;
