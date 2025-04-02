import BatchesDetails from "./BatchesDetails";

const batches = () => {
  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <BatchesDetails />
      </div>
    </div>
  );
};

export default batches;
