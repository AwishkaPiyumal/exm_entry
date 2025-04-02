import FacultyDetails from "./FacultyDetails";

const faculties = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <FacultyDetails />
      </div>
    </div>
  );
};

export default faculties;
