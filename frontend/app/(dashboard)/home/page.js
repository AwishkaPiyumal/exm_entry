"use client";

import { useUser } from "@/utils/useUser";
import { useEffect, useState } from "react";

const Home = () => {
  const { data: user, isLoading } = useUser();
  const [RoleComponent, setRoleComponent] = useState(null);

  useEffect(() => {
    // Dynamically import the correct component
    async function loadRoleComponent() {
      let Component;
      switch (user.role_id) {
        case "1":
          Component = (await import("./AdminHome")).default;
          break;
        case "2":
          Component = (await import("./DeanHome")).default;
          break;
        case "3":
          Component = (await import("./HodHome")).default;
          break;
        case "4":
          Component = (await import("./ManagerHome")).default;
          break;
        case "5":
          Component = (await import("./StudentHome")).default;
          break;
        default:
          window.location.href = "/";
          return;
      }

      setRoleComponent(() => Component);
    }

    if (user) {
      loadRoleComponent();
    }
  }, [user]);

  // Show loading state while the component is being imported
  if (!RoleComponent)
    return (
      <div
        className={`left-0 top-0 w-full h-full flex justify-center items-center`}
      >
        <img
          className="w-20 h-20 animate-spin "
          src="https://www.svgrepo.com/show/491270/loading-spinner.svg"
          alt="Loading icon"
        />
      </div>
    );

  return <RoleComponent />;
};

export default Home;
