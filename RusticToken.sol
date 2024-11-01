// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

abstract contract TokenInterface {
    function totalSupply() external view virtual  returns (uint256);
    function balanceOf(address account) external view virtual  returns (uint256);
    function transfer(address recipient, uint256 amount) external virtual  returns (bool);
    function approve(address spender, uint256 amount) external virtual  returns (bool);
    function transferFrom(address spender, address recipient, uint256 amount) external virtual  returns (bool);
    function allowance(address owner, address spender) external view virtual  returns (uint256);
    function burn(uint256 amount) external virtual  returns (bool);
    function burnFrom(address from, uint256 amount) external virtual  returns (bool);
    function mintMinerRewards(address miner) external virtual  returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amountApproved);
    event RewardDistributes(address indexed miner, uint256 amount);
}

contract RusticToken is TokenInterface {
    string public  name = "RusticToken";
    string public symbol = "RSTQ";
    address public owner;
    uint8 public decimals;
    uint256 public _totalSupply;
    uint256 public maxSupply;
    uint256 public blockReward;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    constructor() {
        name;
        symbol;
        owner = msg.sender;
        decimals = 18;
        _totalSupply = 10000000 * (10 ** uint(decimals));
        balances[owner] = _totalSupply;
        maxSupply = 20000000 * (10 ** uint(decimals));
        blockReward = 50 * (10 ** uint(decimals));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can perform this function");
        _;
    }

    modifier validAddress(address account) {
        require(account != address(0), "Invalid address");
        _;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function allowance(address _owner, address spender) external view override returns (uint256) {
        return allowed[_owner][spender];
    }

    function transfer(address recipient, uint256 amount) external override validAddress(recipient) returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient Balance.");
        
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount); 
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        amount = amount * (10 ** uint(decimals));
        require(_totalSupply + amount <= maxSupply, "Exceeding the Maximum Supply of Tokens");
        
        _totalSupply += amount;
        balances[owner] += amount;
        
        emit Transfer(address(0), owner, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override validAddress(spender) returns (bool) {
        allowed[msg.sender][spender] = amount;
        
        emit Approval(msg.sender, spender, amount); 
        return true;
    }

    function transferFrom(address spender, address recipient, uint256 amount) external override validAddress(recipient) returns (bool) {
        require(balances[spender] >= amount, "Insufficient Balance.");
        require(allowed[spender][msg.sender] >= amount, "Allowance exceeded.");
        
        balances[spender] -= amount;
        balances[recipient] += amount;
        allowed[spender][msg.sender] -= amount;
        
        emit Transfer(spender, recipient, amount); 
        return true;
    }

    function burn(uint256 amount) external override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient Balance to burn");
        
        balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        emit Transfer(msg.sender, address(0), amount); 
        return true;
    }

    function burnFrom(address account, uint256 amount) external override returns (bool) {
        require(allowed[account][msg.sender] >= amount, "Allowance exceeded.");
        require(balances[account] >= amount, "Insufficient balance to burn.");
        
        balances[account] -= amount;
        _totalSupply -= amount;
        allowed[account][msg.sender] -= amount;
        
        emit Transfer(account, address(0), amount); 
        return true;
    }

    function mintMinerRewards(address miner) external onlyOwner validAddress(miner) override returns (bool) {
        balances[miner] += blockReward;
        _totalSupply += blockReward;
        
        emit Transfer(address(0), miner, blockReward);
        emit RewardDistributes(miner, blockReward);
        return true;
    }
}

