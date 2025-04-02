"use client";

import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { useEffect, useRef, useState } from "react";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { login } from "@/utils/apiRequests/auth.api";
import { useMutation } from "@tanstack/react-query";
import { FaEye, FaEyeSlash } from "react-icons/fa6";
import Footer from "@/components/Footer";

const Login = () => {
  const [formData, setFormData] = useState({
    remember_me: true,
  });
  const [btnEnable, setBtnEnable] = useState(false);
  const router = useRouter();
  const loginBtnRef = useRef(null);
  const [protectedPass, setProtectedPass] = useState(true);

  const { mutate } = useMutation({
    mutationFn: login,
    onSuccess: (res) => {
      toast.success(res.message);
      setFormData((cur) => ({
        remember_me: true,
      }));
      router.replace("/home");
    },
    onError: (err) => {
      toast.error("Invalid username or password");
      setFormData((cur) => ({ ...cur, password: "" }));
    },
  });

  const onFormDataChanged = (e) => {
    if (e?.target) {
      setFormData((curData) => ({
        ...curData,
        [e.target?.name]: e.target?.value,
      }));
    } else if (typeof e == "boolean") {
      setFormData((curData) => ({ ...curData, remember_me: e }));
    }
  };

  const onFormSubmitted = async () => {
    try {
      mutate(formData);
    } catch (err) {
      console.log(err);
      console.log(err.response?.data?.message || "Login failed");
    }
  };

  useEffect(() => {
    const isFormValid = formData.user_name_or_email && formData.password;
    setBtnEnable(isFormValid);
  }, [formData]);

  return (
    <div
      className="flex flex-col justify-between h-full"
      onKeyDown={(e) => {
        if (e.key == "Enter") {
          loginBtnRef.current.click();
        }
      }}
    >
      <div className="bg-white rounded-lg shadow-lg w-[85%] sm:w-[425px] p-6 mt-6 self-center">
        <div className="flex justify-between items-center border-b pb-2 mb-4">
          <h3 className="text-lg font-semibold">Sign in</h3>
        </div>
        <div className="grid gap-4 py-4">
          <div className="flex flex-col gap-1 sm:grid sm:grid-cols-4 sm:items-center sm:gap-4">
            <Label
              htmlFor="user_name_or_email"
              className="sm:text-right pl-1 sm:pl-0"
            >
              User name
            </Label>
            <Input
              id="user_name_or_email"
              name="user_name_or_email"
              className="sm:col-span-3"
              onChange={(e) => onFormDataChanged(e)}
              onBlur={(e) => {
                e.target.value = e.target.value.trim();
                onFormDataChanged(e);
              }}
              value={formData.user_name_or_email || ""}
              placeholder="Enter your user name or email"
            />
          </div>
          <div className="flex flex-col gap-1 sm:grid sm:grid-cols-4 sm:items-center sm:gap-4">
            <Label htmlFor="password" className="sm:text-right pl-1 sm:pl-0">
              Password
            </Label>
            <div className="sm:col-span-3 relative">
              <Input
                id="password"
                name="password"
                type={protectedPass ? "password" : "text"}
                className="w-full"
                onChange={(e) => onFormDataChanged(e)}
                onBlur={(e) => {
                  e.target.value = e.target.value.trim();
                  onFormDataChanged(e);
                }}
                value={formData.password || ""}
                placeholder="Enter your password"
              />
              {protectedPass ? (
                <FaEye
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setProtectedPass(false)}
                />
              ) : (
                <FaEyeSlash
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setProtectedPass(true)}
                />
              )}
            </div>
          </div>

          <div className="grid grid-cols-4 gap-4 mt-0 sm:mt-4">
            <Label className="text-right hidden sm:inline-block"></Label>
            <div className="items-top flex flex-col sm:flex-row sm:space-x-2 col-span-3 sm:justify-between sm:items-center gap-4 sm:gap-0">
              <div className=" flex space-x-2  items-center">
                <Checkbox
                  id="remember_me"
                  onCheckedChange={(e) => onFormDataChanged(e)}
                  checked={formData?.remember_me === true}
                />
                <div className="grid gap-1.5 leading-none">
                  <label
                    htmlFor="remember_me"
                    className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 cursor-pointer"
                  >
                    Remember me
                  </label>
                </div>
              </div>
              <div className="flex space-x-2  items-center">
                <Link
                  href="/reset-password"
                  className="text-sm text-blue-700 self-end"
                >
                  forgot password?
                </Link>
              </div>
            </div>
          </div>
        </div>
        <div className="flex justify-end space-x-2 mt-0 sm:mt-4">
          <Button
            type="button"
            ref={loginBtnRef}
            disabled={!btnEnable}
            onClick={onFormSubmitted}
          >
            Sign In
          </Button>
        </div>
      </div>
      <Footer />
    </div>
  );
};

export default Login;
