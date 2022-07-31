// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract ManualToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18; //strongly suggested default, avoid changing it 
    uint256 public totalSupply; // how many tokens to initial at the beginning

    // this creates an array with all balances 
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    // address1 allows address2 to spend uint256 amount of tokens 

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to,uint256 value);

    // This geneartes a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
    /**
        Constructor function

        Initializes contract with initial supply tokens  to the creator of the contract
     */
     constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
     ){
        totalSupply = initialSupply * 10**uint256(decimals); //update total supply with the decimal amount
        balanceIf[msg.sender] = totalSupply; // Give the creator all initial tokens
        name = tokenName; //set the name of display purposes
        symbol = tokenSymbol; //set the symbol for display purposes
     }

    /**
    Internal transfer, only can be called by this contract
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        // Prevent trandfer to 0x0 address. Use burn() instread
        require(_to != address(0x0));
        // check if the sender has enough
        require(balanceOf[_from] >= _value);
        // check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Save this for an assertion in the future
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add to the sender
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }
    function transferFrom(address _from, address _to, uint256 value) public returns(bool success) {
            require(_value <= allowance[_from][msg.sender])
            allowance[_from][msg.sender] -= _value
            transfer(_from, _to, value)
            return true
    }
}