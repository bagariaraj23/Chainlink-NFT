import React from "react";
import { Route, Routes } from "react-router-dom";
import Home from "../views/home";
import About from "../views/about/about";
import Explore from "../views/marketplace/explore";
import CreateNFT from "../views/create NFT/createNFT";

const MyRoutes = () => {
  return (
    <Routes>
      <Route exact path="/" Component={Home} />
      <Route path="/about" Component={About} />
      <Route path="/explore" Component={Explore} />
      <Route path="/create" Component={CreateNFT} />
    </Routes>
  );
};

export default MyRoutes;
