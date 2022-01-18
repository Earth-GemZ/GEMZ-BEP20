// SPDX-License-Identifier: GPL-3.0

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

pragma solidity ^0.8.3;

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}