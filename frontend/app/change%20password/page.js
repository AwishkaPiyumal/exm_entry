"use client";
import React, { useState } from "react";
import { toast } from "sonner";
import { useMutation } from "@tanstack/react-query";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { changePassword } from "@/utils/apiRequests/auth.api";
import { useRouter } from "next/navigation";

const ChangePassword = () => {
  const router = useRouter();

  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");

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
    <div className="flex items-center justify-center h-full">
      <div className="bg-white rounded-lg shadow-lg w-[425px] p-6">
        <div className="flex justify-between items-center border-b pb-2 mb-4">
          <h3 className="text-lg font-semibold">Change Password</h3>
        </div>
        <div className="grid gap-4 py-4">
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="currentPassword" className="text-right">
              Current Password
            </Label>
            <Input
              type="password"
              className="col-span-3"
              id="currentPassword"
              value={currentPassword}
              onChange={(e) => setCurrentPassword(e.target.value)}
              placeholder="Enter your current password"
              required
            />
          </div>
          <div className="grid grid-cols-4 items-center gap-4">
            <Label htmlFor="newPassword" className="text-right">
              New Password
            </Label>
            <Input
              type="password"
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
              Confirm Password
            </Label>
            <Input
              type="password"
              className="col-span-3"
              id="confirmPassword"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Re-enter your new password"
              required
            />
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
