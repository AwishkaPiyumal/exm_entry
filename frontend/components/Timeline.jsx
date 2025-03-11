const Timeline = ({ timelineData }) => {
  const options = {
    dateStyle: "long",
    timeStyle: "short",
  };

  return (
    <ol className="relative border-s border-gray-200 dark:border-gray-700">
      {timelineData?.map((item, index) => (
        <li key={index} className="mb-10 ms-4">
          <div className="absolute w-3 h-3 bg-gray-200 rounded-full mt-1.5 -start-1.5 border border-white dark:border-gray-900 dark:bg-gray-700"></div>
          <time className="mb-1 text-sm font-normal leading-none text-gray-400 dark:text-gray-500">
            {new Intl.DateTimeFormat("en-US", options).format(
              new Date(item.date_time)
            )}
          </time>
          <h3 className="text-base font-semibold flex items-center gap-2 text-gray-900 dark:text-white capitalize">
            {item.status_from}
            <svg
              className="w-3 h-3 rtl:rotate-180"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 14 10"
            >
              <path
                stroke="currentColor"
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="2"
                d="M1 5h12m0 0L9 1m4 4L9 9"
              />
            </svg>
            {item.status_to}
          </h3>
          <div className="mb-1 text-base font-normal text-gray-500 dark:text-gray-400">
            {item.remark}
          </div>
          <p className="mb-4 text-sm italic text-end text-gray-500 dark:text-gray-600">
            {item.user_name}
          </p>
        </li>
      ))}
    </ol>
  );
};

export default Timeline;
