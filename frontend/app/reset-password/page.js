"use client";
import React, { useState } from "react";
import { useSearchParams } from "next/navigation";
import { toast } from "sonner";
import { forgotPassword, resetPassword } from "@/utils/apiRequests/auth.api";
import { useRouter } from "next/navigation";
import { useMutation } from "@tanstack/react-query";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import Link from "next/link";
import { FaChevronLeft } from "react-icons/fa6";

const ResetPassword = () => {
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [emailOrUsername, setEmailOrUsername] = useState("");
  const router = useRouter();
  const searchParams = useSearchParams();

  const token = searchParams.get("token");

  const { mutate, isPending } = useMutation({
    mutationFn: token ? resetPassword : forgotPassword,
    onSuccess: (res) => {
      toast.success(res.message);
      setNewPassword("");
      setConfirmPassword("");
      setEmailOrUsername("");
      router.replace("/");
    },
    onError: (err) => {

      if (err.status == 429) {
        toast.error(err.response.data.message);
      } else {
        toast.error("Operation failed");
      }
    },
  });

  const handleResetMail = () => {
    if (!emailOrUsername) {
      toast.error("Enter your email or username");
      return;
    }

    mutate({
      emailOrUsername,
    });
  };

  if (!token) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="bg-white rounded-lg shadow-lg w-[425px] p-6">
          <div className="flex justify-between items-center border-b pb-2 mb-4">
            <h3 className="text-lg font-semibold">Reset Password</h3>
          </div>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="emailOrUsername" className="text-right">
                Email or Username
              </Label>
              <Input
                className="col-span-3"
                id="emailOrUsername"
                value={emailOrUsername}
                onChange={(e) => setEmailOrUsername(e.target.value)}
                placeholder="Enter your email or username"
                required
              />
            </div>
          </div>
          <div className="flex justify-between space-x-2 mt-4">
            <Link href="/" className="flex items-center text-blue-500 text-sm">
              <FaChevronLeft />
              &nbsp;Sign in
            </Link>
            <Button disabled={isPending} onClick={handleResetMail}>
              {isPending ? "Sending..." : "Send Reset Link"}
            </Button>
          </div>
        </div>
      </div>
    );
  }

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (confirmPassword == "" || newPassword == "") {
      toast.error("All fields are required.");
      return;
    }
    if (newPassword != confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }

    const token = searchParams.get("token");
    if (!token) {
      toast.error("Invalid reset token.");
      return;
    }

    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }

    if (newPassword.length < 8) {
      toast.error("Password must be at least 8 characters long.");
      return;
    }

    mutate({
      token,
      newPassword,
    });
  };

  return (
    <div className="flex items-center justify-center h-full">
      <div className="bg-white rounded-lg shadow-lg w-[425px] p-6">
        <div className="flex justify-between items-center border-b pb-2 mb-4">
          <h3 className="text-lg font-semibold">Reset Password</h3>
        </div>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="newPassword" className="text-right">
              New password
            </Label>
            <Input
              className="col-span-3"
              id="newPassword"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="Enter your new password"
              required
            />
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="confirmPassword" className="text-right">
              Confirm password
            </Label>
            <Input
              className="col-span-3"
              id="confirmPassword"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Re-enter your new password"
              required
            />
          </div>
        </div>
        <div className="flex justify-between space-x-2 mt-4">
          <Link href="/" className="flex items-center text-blue-500 text-sm">
            <FaChevronLeft />
            &nbsp;Sign in
          </Link>
          <Button disabled={isPending} onClick={handleSubmit}>
            {isPending ? "Resetting..." : "Reset Password"}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default ResetPassword;
