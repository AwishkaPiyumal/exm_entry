"use client";

import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { useEffect, useState } from "react";

import Link from "next/link";
import axiosInstance from "@/lib/axiosInstance";
import { useRouter } from "next/navigation";

const Login = () => {
  const [formData, setFormData] = useState({
    remember_me: true,
  });
  const [btnEnable, setBtnEnable] = useState(false);
  const router = useRouter();

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
      const { data } = await axiosInstance.post("/auth/login", formData);

      router.push("/home");
    } catch (err) {
      console.log(err);
      console.log(err.response?.data?.message || "Login failed");
    }
    setFormData({ remember_me: true });
  };

  useEffect(() => {
    const isFormValid = formData.user_name_or_email && formData.password;
    setBtnEnable(isFormValid);
  }, [formData]);

  return (
    <div className="flex justify-center items-center h-full">
      <div className="bg-white rounded-lg shadow-lg w-[425px] p-6">
        <div className="flex justify-between items-center border-b pb-2 mb-4">
          <h3 className="text-lg font-semibold">Sign in</h3>
        </div>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="user_name_or_email" className="text-right">
              User name
            </Label>
            <Input
              id="user_name_or_email"
              name="user_name_or_email"
              className="col-span-3"
              onChange={(e) => onFormDataChanged(e)}
              onBlur={(e) => {
                e.target.value = e.target.value.trim();
                onFormDataChanged(e);
              }}
              value={formData.user_name_or_email || ""}
              placeholder="Enter your user name or email"
            />
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="password" className="text-right">
              Password
            </Label>
            <Input
              id="password"
              name="password"
              // type="password"
              className="col-span-3"
              onChange={(e) => onFormDataChanged(e)}
              onBlur={(e) => {
                e.target.value = e.target.value.trim();
                onFormDataChanged(e);
              }}
              value={formData.password || ""}
              placeholder="Enter your password"
            />
          </div>

          <div className="grid grid-cols-4 gap-4 mt-4">
            <Label className="text-right"></Label>
            <div className="items-top flex space-x-2 col-span-3 justify-between items-center">
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
              <div className=" flex space-x-2  items-center">
                <Link href="#" className="text-sm text-blue-700 self-end">
                  forgot password?
                </Link>
              </div>
            </div>
          </div>
        </div>
        <div className="flex justify-end space-x-2 mt-4">
          <Button type="button" disabled={!btnEnable} onClick={onFormSubmitted}>
            Sign In
          </Button>
        </div>
      </div>
    </div>
  );
};

export default Login;
