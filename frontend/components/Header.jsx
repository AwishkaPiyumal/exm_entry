import Image from "next/image";
import UoV_Logo from "./../images/UoV_Logo.png";

const Header = () => {
  return (
    <div className="fixed h-20 z-50 w-full bg-white flex items-center px-5">
      <Image src={UoV_Logo} alt="UOV logo" height={70} width={70} />
      <h1 className="uppercase grow text-3xl text-center">uov examination</h1>
    </div>
  );
};

export default Header;
