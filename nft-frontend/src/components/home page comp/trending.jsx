import React from "react";
import { Card, CardBody, Typography } from "@material-tailwind/react";

const TrendingNFT = ({ image, name, imageAlt }) => {
  return (
    <div className="flex justify-center">
      <Card className="mt-6 dark:bg-primary-950 w-full">
        <CardBody className="flex flex-row">
          <div className="flex justify-center w-1/2">
            <img src={image} alt={imageAlt} className="object-contain" />
          </div>
          <div className="flex flex-col justify-center w-1/2">
            <Typography className="text-black dark:text-white" variant="h5">
              {name}
            </Typography>
          </div>
        </CardBody>
      </Card>
    </div>
  );
};

export default TrendingNFT;
