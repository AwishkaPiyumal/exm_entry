"use client";
import React, { useState } from "react";
import { toast } from "sonner";
import { useMutation } from "@tanstack/react-query";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { changePassword } from "@/utils/apiRequests/auth.api";
import { useRouter } from "next/navigation";
import { FaEye, FaEyeSlash } from "react-icons/fa6";

const ChangePassword = () => {
  const router = useRouter();

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [curProtectedPass, setCurProtectedPass] = useState(true);
  const [newProtectedPass, setNewProtectedPass] = useState(true);
  const [conProtectedPass, setConProtectedPass] = useState(true);

  const { mutate, isPending } = useMutation({
    mutationFn: changePassword,
    onSuccess: (res) => {
      toast.success(res.message);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
      router.replace("/home");
    },
    onError: (err) => {
      toast.error(err.response?.data?.message || "Failed to change password.");
    },
  });

  const handleSubmit = (e) => {
    e.preventDefault();

    if (!currentPassword || !newPassword || !confirmPassword) {
      toast.error("All fields are required.");
      return;
    }

    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match.");
      return;
    }

    if (newPassword.length < 8) {
      toast.error("New password must be at least 8 characters long.");
      return;
    }

    mutate({ currentPassword, newPassword });
  };

  return (
    <div className="flex items-center justify-center h-full px-2 sm:px-0">
      <div className="bg-white rounded-lg shadow-lg w-full sm:w-[425px] p-6">
        <div className="flex justify-between items-center border-b pb-2 mb-4">
          <h3 className="text-lg font-semibold">Change Password</h3>
        </div>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="currentPassword" className="text-right">
              Current Password
            </Label>
            <div className="sm:col-span-3 relative">
              <Input
                type={curProtectedPass ? "password" : "text"}
                className="col-span-3"
                id="currentPassword"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
                onBlur={(e) => {
                  e.target.value = e.target.value.trim();
                  setCurrentPassword(e.target.value);
                }}
                placeholder="Enter your current password"
                required
              />
              {curProtectedPass ? (
                <FaEye
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setCurProtectedPass(false)}
                />
              ) : (
                <FaEyeSlash
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setCurProtectedPass(true)}
                />
              )}
            </div>
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="newPassword" className="text-right">
              New Password
            </Label>
            <div className="sm:col-span-3 relative">
              <Input
                type={newProtectedPass ? "password" : "text"}
                className="col-span-3"
                id="newPassword"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                onBlur={(e) => {
                  e.target.value = e.target.value.trim();
                  setNewPassword(e.target.value);
                }}
                placeholder="Enter your new password"
                required
              />
              {newProtectedPass ? (
                <FaEye
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setNewProtectedPass(false)}
                />
              ) : (
                <FaEyeSlash
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setNewProtectedPass(true)}
                />
              )}
            </div>
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="confirmPassword" className="text-right">
              Confirm Password
            </Label>
            <div className="sm:col-span-3 relative">
              <Input
                type={conProtectedPass ? "password" : "text"}
                className="col-span-3"
                id="confirmPassword"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                onBlur={(e) => {
                  e.target.value = e.target.value.trim();
                  setConfirmPassword(e.target.value);
                }}
                placeholder="Re-enter your new password"
                required
              />
              {conProtectedPass ? (
                <FaEye
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setConProtectedPass(false)}
                />
              ) : (
                <FaEyeSlash
                  className="absolute right-3 top-3 cursor-pointer"
                  onClick={() => setConProtectedPass(true)}
                />
              )}
            </div>
          </div>
        </div>
        <div className="flex justify-end space-x-2 mt-4">
          <Button disabled={isPending} onClick={handleSubmit}>
            {isPending ? "Changing..." : "Change Password"}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default ChangePassword;
