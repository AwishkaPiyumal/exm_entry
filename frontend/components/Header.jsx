import Image from "next/image";
import UoV_Logo from "./../images/UoV_Logo.png";

const Header = () => {
  return (
    <div className="fixed h-14 sm:h-16 md:h-18 lg:h-20 z-50 w-full bg-white flex items-center px-5">
      <Image
        src={UoV_Logo}
        alt="UOV logo"
        className="h-[40px] w-[40px] sm:h-[50px] sm:w-[50px] md:h-[60px] md:w-[60px] lg:h-[70px] lg:w-[70px]"
      />
      <h1 className="uppercase grow text-xl md:text-2xl lg:text-3xl text-center">
        uov examination
      </h1>
    </div>
  );
};

export default Header;
