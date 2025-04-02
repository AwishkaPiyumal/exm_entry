import ManagerDetails from "./ManagerDetails";

const managers = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <ManagerDetails />
      </div>
    </div>
  );
};

export default managers;
