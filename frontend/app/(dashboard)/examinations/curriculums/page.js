import CurriculumsDetails from "./CurriculumsDetails";

const curriculums = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <CurriculumsDetails />
      </div>
    </div>
  );
};

export default curriculums;
