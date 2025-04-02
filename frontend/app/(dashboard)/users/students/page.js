import StudentDetails from "./StudentDetails";

const students = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <StudentDetails />
      </div>
    </div>
  );
};

export default students;
