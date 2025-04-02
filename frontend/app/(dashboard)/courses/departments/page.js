import DepartmentDetails from "./DepartmentDetails";

const departments = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <DepartmentDetails />
      </div>
    </div>
  );
};

export default departments;
