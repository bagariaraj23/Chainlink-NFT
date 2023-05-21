import React from "react";

const Partner = ({ image, imageAlt, partnerName }) => {
  return (
    <div className="flex flex-col items-center w-full hover:scale-125 transition duration-300 ease-in-out">
      <img src={image} alt={imageAlt} className="object-contain self-center " />
      <h5 className="text-black dark:text-white">{partnerName}</h5>
    </div>
  );
};

export default Partner;
