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

import 'Ownable.sol';
import 'SafeMath.sol';
import 'Address.sol';
import 'IERC20.sol';

contract EarthGemZ is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) private _isExcludedFromFee;

    address[] private _excluded;

    struct ValuesResult {
        uint256 tTransferAmount;
        uint256 tCharity;
        uint256 tTeam;
        uint256 tMarketing;
        uint256 tBurn;
    }

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 100 * 10**6 * 10**18;
    uint256 private _tFeeTotal;

    string private constant _name = "Earth GemZ";
    string private constant _symbol = "GEMZ";
    uint8 private constant _decimals = 18;
    
    uint256 public _charityFee = 50;
    uint256 private _previousCharityFee = _charityFee;

    uint256 public _teamFee = 25;
    uint256 private _previousTeamFee = _teamFee;

    uint256 public _marketingFee = 25;
    uint256 private _previousMarketingFee = _marketingFee;

    uint256 public _burnFee = 25;
    uint256 private _previousBurnFee = _burnFee;

    uint256 public _maxTxAmount = 540 * 10**3 * 10**18; // 0.005
    uint256 private constant _TIMELOCK = 0; //31556926 1 year

    event CharityFeePercentChanged(uint256 oldValue, uint256 newValue);
    event TeamFeePercentChanged(uint256 oldValue, uint256 newValue);
    event MarketingFeePercentChanged(uint256 oldValue, uint256 newValue);
    event BurnFeePercentChanged(uint256 oldValue, uint256 newValue);
    event MaxTxPermillChanged(uint256 oldValue, uint256 newValue);


    constructor (address payable charityAddress, address payable teamAddress, address payable marketingAddress, address payable burnAddress) {
        _tOwned[owner()] = _tTotal;

        // exclude owner and this contract from fee
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        setCharityAddress(charityAddress);
        setTeamAddress(teamAddress);
        setMarketingAddress(marketingAddress);
        setBurnAddress(burnAddress);

        increaseTimeLockBy(_TIMELOCK);
        
        emit Transfer(address(0), owner(), _tTotal);
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function balanceOfT(address account) external view onlyOwner() returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferOwnership(address newOwner) external virtual onlyOwner() onlyUnlocked() {
        emit OwnershipTransferred(owner(), newOwner);
        _transfer(owner(), newOwner, balanceOf(owner()));
        updateOwner(newOwner);
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }
    
    function excludeFromFee(address account) public override onlyOwner onlyUnlocked(){
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setCharityFeePercent(uint256 charityFee) external onlyOwner() onlyUnlocked(){
        require(charityFee <= 50, "Cannot set percentage over 0.5%");
        emit CharityFeePercentChanged(_charityFee, charityFee);
        _charityFee = charityFee;
    }

    function setTeamFeePercent(uint256 teamFee) external onlyOwner() onlyUnlocked(){
        require(teamFee <= 25, "Cannot set percentage over 0.25%");
        emit TeamFeePercentChanged(_teamFee, teamFee);
        _teamFee = teamFee;
    }

    function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() onlyUnlocked(){
        require(marketingFee <= 25, "Cannot set percentage over 0.25%");
        emit MarketingFeePercentChanged(_marketingFee, marketingFee);
        _marketingFee = marketingFee;
    }
    
    function setBurnFeePercent(uint256 burnFee) external onlyOwner() onlyUnlocked(){
        require(burnFee <= 25, "Cannot set percentage over 0.25%");
        emit BurnFeePercentChanged(_burnFee, burnFee);
        _burnFee = burnFee;
    }
   
    function setMaxTxPermill(uint256 maxTxPermill) external onlyOwner() onlyUnlocked(){
        emit MaxTxPermillChanged(_maxTxAmount, _tTotal.mul(maxTxPermill).div(10**3));
        _maxTxAmount = _tTotal.mul(maxTxPermill).div(
            10**3
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256) {
        ValuesResult memory valuesResult = ValuesResult(0, 0, 0, 0, 0);

        _getTValues(tAmount, valuesResult);

        return (valuesResult.tTransferAmount, valuesResult.tCharity, valuesResult.tTeam, valuesResult.tMarketing, valuesResult.tBurn);
    }

    function _getTValues(uint256 tAmount, ValuesResult memory valuesResult) private view returns (ValuesResult memory) {
        {
            uint256 tCharity = calculateCharityFee(tAmount);
            valuesResult.tCharity = tCharity;
        }
        {
            uint256 tTeam = calculateTeamFee(tAmount);
            valuesResult.tTeam = tTeam;
        }
        {
            uint256 tMarketing = calculateMarketingFee(tAmount);
            valuesResult.tMarketing = tMarketing;
        }
        {
            uint256 tBurn = calculateBurnFee(tAmount);
            valuesResult.tBurn = tBurn;
        }

        valuesResult.tTransferAmount = tAmount.sub(valuesResult.tCharity).sub(valuesResult.tTeam).sub(valuesResult.tMarketing).sub(valuesResult.tBurn);
        return valuesResult;
    }
    
    function _takeCharity(uint256 tCharity) private {
            _tOwned[charity()] = _tOwned[charity()].add(tCharity);
    }

    function _takeTeam(uint256 tTeam) private {
            _tOwned[team()] = _tOwned[team()].add(tTeam);
    }
    
    function _takeMarketing(uint256 tMarketing) private {
            _tOwned[marketing()] = _tOwned[marketing()].add(tMarketing);
    }

    function _takeBurn(uint256 tBurn) private {
            _tOwned[burn()] = _tOwned[burn()].add(tBurn);
    }

    function calculateCharityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_charityFee).div(
            10**4
        );
    }

    function calculateTeamFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_teamFee).div(
            10**4
        );
    }

    function calculateMarketingFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_marketingFee).div(
            10**4
        );
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            10**4
        );
    }
    
    function removeAllFee() private {
        // if(_taxFee == 0) return;
        _previousCharityFee = _charityFee;
        _previousTeamFee = _teamFee;
        _previousMarketingFee = _marketingFee;
        _previousBurnFee = _burnFee;
        
        _charityFee = 0;
        _teamFee = 0;
        _marketingFee = 0;
        _burnFee = 0;
    }
    
    function restoreAllFee() private {
        _charityFee = _previousCharityFee;
        _teamFee = _previousTeamFee;
        _marketingFee = _previousMarketingFee;
        _burnFee = _previousBurnFee;
    }
    
    function isExcludedFromFee(address account) external view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
    * TRANSFER
    */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if(from != owner() && to != owner())
            require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from,to,amount,takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        if(!takeFee)
            removeAllFee();
        _transferStandard(sender, recipient, amount);

        if(!takeFee)
            restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {
        // (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tCharity, uint256 tMaintenance, uint256 tLiquidityWallet) = _getValues(tAmount);
        (uint256 tTransferAmount, uint256 tCharity, uint256 tTeam, uint256 tMarketing, uint256 tBurn) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        // _takeLiquidity(tLiquidity);
        _takeCharity(tCharity);
        _takeTeam(tTeam);
        _takeMarketing(tMarketing);
        _takeBurn(tBurn);
        // _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

}

