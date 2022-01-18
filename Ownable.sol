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

import "Context.sol";
import 'SafeMath.sol';

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    using SafeMath for uint256;
    address private _owner;
    address payable private _charityAddress;
    address payable private _teamAddress;
    address payable private _marketingAddress;
    address payable private _burnAddress;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event CharityAddressChanged(address oldAddress, address newAddress);
    event TeamAddressChanged(address oldAddress, address newAddress);
    event MarketingAddressChanged(address oldAddress, address newAddress);
    event BurnAddressChanged(address oldAddress, address newAddress);
    event TimeLockChanged(uint256 previousValue, uint256 newValue);

    // set timelock
    enum Functions { excludeFromFee }
    uint256 public timelock = 0;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    modifier onlyUnlocked() {
        require(timelock <= block.timestamp, "Function is timelocked");
        _;
    }

    //lock timelock
    function increaseTimeLockBy(uint256 _time) public onlyOwner onlyUnlocked {
        uint256 _previousValue = timelock;
        timelock = block.timestamp.add(_time);
        emit TimeLockChanged(_previousValue ,timelock);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function lockDue() public view returns (uint256) {
        return timelock;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function updateOwner(address newOwner) internal onlyOwner() onlyUnlocked() {
        _owner = newOwner;
    }
    
    function charity() public view returns (address payable)
    {
        return _charityAddress;
    }

    function team() public view returns (address payable)
    {
        return _teamAddress;
    }

    function marketing() public view returns (address payable)
    {
        return _marketingAddress;
    }
    
    function burn() public view returns (address payable)
    {
        return _burnAddress;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function excludeFromFee(address account) public virtual onlyOwner() onlyUnlocked(){
    }
    
    function setCharityAddress(address payable charityAddress) public virtual onlyOwner onlyUnlocked()
    {
        //require(_charity == address(0), "Charity address cannot be changed once set");
        emit CharityAddressChanged(_charityAddress, charityAddress);
        _charityAddress = charityAddress;
        // excludeFromReward(charityAddress);
        excludeFromFee(charityAddress);
    }

    function setTeamAddress(address payable teamAddress) public virtual onlyOwner onlyUnlocked()
    {
        //require(_maintenance == address(0), "Maintenance address cannot be changed once set");
        emit TeamAddressChanged(_teamAddress, teamAddress);
        _teamAddress = teamAddress;
        // excludeFromReward(maintenanceAddress);
        excludeFromFee(teamAddress);
    }

    function setMarketingAddress(address payable marketingAddress) public virtual onlyOwner onlyUnlocked()
    {
        //require(_maintenance == address(0), "Liquidity address cannot be changed once set");
        emit MarketingAddressChanged(_marketingAddress, marketingAddress);
        _marketingAddress = marketingAddress;
        // excludeFromReward(liquidityWalletAddress);
        excludeFromFee(marketingAddress);
    }

    function setBurnAddress(address payable burnAddress) public virtual onlyOwner onlyUnlocked()
    {
        //require(_maintenance == address(0), "Liquidity address cannot be changed once set");
        emit BurnAddressChanged(_burnAddress, burnAddress);
        _burnAddress = burnAddress;
        // excludeFromReward(liquidityWalletAddress);
        excludeFromFee(burnAddress);
    }

}