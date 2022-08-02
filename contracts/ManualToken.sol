// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface tokenRecipient {
    function receiveApproval(
        address _from,
        uint256 _value,
        address _to,
        bytes calldata _extraData
    ) external;
}

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
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This geneartes a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
        Constructor function
    *
        Initializes contract with initial supply tokens  to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**uint256(decimals); //update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply; // Give the creator all initial tokens
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

    /**
    Transfer tokens
    *
    Send `_value` tokens to `_to` from your account
    *
     @param _to The address of the recipient
     @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    Transfer tokens from other address
    *
    Send `_value` tokens to `_to` on behalf of `_from`
    *
    @param _from The address of the sender
    @param _to The address of the recipient
    @param _value the amount to send
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
    Approve function :
    Set allowance for other user
    Allow `_spender` to spend no more than `_value` tokens on your behalf
    *
    @param _spender The address authorized to spend
    @param _value The max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    approvalAndCall function:
    Allow `_spender` to spend no more than `_value` tokens on your behalf, 
    and then ping the contract about it
    *
    @param _spender The address authroized to spend
    @param _value The max amount they can spend
    @param _extraData Some extra information to send to the approved contract
     */
    function approveAndCall(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
        Destroy tokens
        Remove `_value` tokens from the system irreversibly
    *
        @param _value The amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value); //check if the sender has enough
        balanceOf[msg.sender] -= _value; //Subtract from sender
        totalSupply -= _value; //Update totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    // Destroy tokens from other account
    // Remove `_value` tokens from the system irreversibly on behalf of `_from`.

    // @param _from The address of the sender
    // @param _vale The amount of money to burn

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value); //check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]); //check allowance
        balanceOf[_from] -= _value; //subtract from the targeted balance
        allowance[_from][msg.sender] -= _value; //subtract from sender's allowance
        totalSupply -= _value; //update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}
