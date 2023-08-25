// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// import "./Math.sol";
library SafeMath {
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction underflow");
        uint256 c = a - b;
        return c;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}


abstract contract ERC20Interface {
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address tokenOwner) public view virtual returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view virtual returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function close() public virtual;
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

abstract contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) public virtual;
}

contract PHRToken is ERC20Interface {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    address payable owner;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor(address primaryAddress) {
        symbol = "PHR";
        name = "PHR Token";
        decimals = 2;
        _totalSupply = 100000 * 10 ** uint256(decimals);
        owner = payable(primaryAddress);
        balances[primaryAddress] = _totalSupply;
        emit Transfer(address(0), primaryAddress, _totalSupply);
    }

    function balanceOf(
        address tokenOwner
    ) public view override returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function transfer(
        address to,
        uint256 tokens
    ) public override returns (bool success) {
        balances[msg.sender] = balances[msg.sender].safeSub(tokens);
        balances[to] = balances[to].safeAdd(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(
        address spender,
        uint256 tokens
    ) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function allowance(
        address tokenOwner,
        address spender
    ) public view override returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function approveAndCall(
        address spender,
        uint256 tokens,
        bytes calldata data
    ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(
            msg.sender,
            tokens,
            address(this),
            data
        );
        return true;
    }

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    function close() public override{
        require(msg.sender == owner, "this function can remove token from network");
        selfdestruct(owner);
    }
    
}
