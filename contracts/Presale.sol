// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Minimalistic ERC20 Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// SafeMath Implementation
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}

// Custom Ownable Contract
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Presale Contract
contract Presale is Ownable {
    using SafeMath for uint256;

    IERC20 public token;
    IERC20 public usdt;
    IERC20 public usdc;
    uint256 public rate;
    uint256 public weiRaised;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public openingTime;
    uint256 public closingTime;
    address public wallet;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 tokenAmount);

    constructor(
        uint256 _rate,
        address _wallet,
        IERC20 _token,
        IERC20 _usdt,
        IERC20 _usdc,
        uint256 _softCap,
        uint256 _hardCap
    ) {
        require(_rate > 0, "Rate is 0");
        require(_wallet != address(0), "Invalid wallet address");
        require(address(_token) != address(0), "Invalid token address");
        require(address(_usdt) != address(0), "Invalid USDT address");
        require(address(_usdc) != address(0), "Invalid USDC address");
        require(_softCap > 0, "Soft cap is 0");
        require(_hardCap > 0, "Hard cap is 0");

        rate = _rate;
        wallet = _wallet;
        token = _token;
        usdt = _usdt;
        usdc = _usdc;
        softCap = _softCap;
        hardCap = _hardCap;
        openingTime = block.timestamp; // Current time
        closingTime = block.timestamp + 30 * 24 * 60 * 60; // 30 days from now
    }

    function buyTokensWithETH() public payable {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime, "Presale not active");
        uint256 tokens = msg.value.mul(rate);
        weiRaised = weiRaised.add(msg.value);
        require(weiRaised <= hardCap, "Hard cap reached");
        require(token.transfer(msg.sender, tokens), "Token transfer failed");
        emit TokensPurchased(msg.sender, msg.value, tokens);
    }

    function buyTokensWithUSDT(uint256 amount) public {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime, "Presale not active");
        uint256 tokens = amount.mul(rate);
        require(usdt.transferFrom(msg.sender, address(this), amount), "USDT transfer failed");
        weiRaised = weiRaised.add(amount);
        require(weiRaised <= hardCap, "Hard cap reached");
        require(token.transfer(msg.sender, tokens), "Token transfer failed");
        emit TokensPurchased(msg.sender, amount, tokens);
    }

    function buyTokensWithUSDC(uint256 amount) public {
        require(block.timestamp >= openingTime && block.timestamp <= closingTime, "Presale not active");
        uint256 tokens = amount.mul(rate);
        require(usdc.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        weiRaised = weiRaised.add(amount);
        require(weiRaised <= hardCap, "Hard cap reached");
        require(token.transfer(msg.sender, tokens), "Token transfer failed");
        emit TokensPurchased(msg.sender, amount, tokens);
    }

    function withdrawFunds() public onlyOwner {
        require(block.timestamp > closingTime, "Presale not closed");
        require(weiRaised >= softCap, "Soft cap not reached");
        payable(wallet).transfer(address(this).balance);
    }

    receive() external payable {
        buyTokensWithETH();
    }
}
