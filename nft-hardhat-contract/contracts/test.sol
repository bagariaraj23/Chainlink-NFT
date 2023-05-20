// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;



contract Encode  {



    function getNft() external pure returns(bytes memory){

        return  abi.encodePacked([1, 200000]);

    }



}


