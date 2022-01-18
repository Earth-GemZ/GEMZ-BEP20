// SPDX-License-Identifier: MIT

/**
 /$$$$$$$$                       /$$     /$$              /$$$$$$                                   
| $$_____/                      | $$    | $$             /$$__  $$                                  
| $$        /$$$$$$   /$$$$$$  /$$$$$$  | $$$$$$$       | $$  \__/  /$$$$$$  /$$$$$$/$$$$  /$$$$$$$$
| $$$$$    |____  $$ /$$__  $$|_  $$_/  | $$__  $$      | $$ /$$$$ /$$__  $$| $$_  $$_  $$|____ /$$/
| $$__/     /$$$$$$$| $$  \__/  | $$    | $$  \ $$      | $$|_  $$| $$$$$$$$| $$ \ $$ \ $$   /$$$$/ 
| $$       /$$__  $$| $$        | $$ /$$| $$  | $$      | $$  \ $$| $$_____/| $$ | $$ | $$  /$$__/  
| $$$$$$$$|  $$$$$$$| $$        |  $$$$/| $$  | $$      |  $$$$$$/|  $$$$$$$| $$ | $$ | $$ /$$$$$$$$
|________/ \_______/|__/         \___/  |__/  |__/       \______/  \_______/|__/ |__/ |__/|________/
 */

pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}
