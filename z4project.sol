// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract xZ4 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 public constant totalSupply = 7000000000 * 10 ** 18;
    string public constant name = "Z4 project";
    string public constant symbol = "xZ4";
    uint8 public constant decimals = 18;
    address[] private addresses;
    uint256 public rewardAmount = 100 * 10 ** decimals;
    uint256 public minimumBalance = 1000 * 10 ** decimals;
    address private owner;
    mapping(address => bool) private approvedContracts;
    uint256 public purchaseCounter;
    uint256 public rewardThreshold = 1000;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value > 0, "Value must be greater than zero");
        require(_value <= balances[msg.sender], "Insufficient balance");
        require(_to != address(0), "Invalid address");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_value > 0, "Value must be greater than zero");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= allowances[_from][msg.sender], "Insufficient allowance");
        require(_to != address(0), "Invalid address");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(0), "Invalid address");
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function getAllowance(address _owner, address _spender) public view returns (uint256) {
        require(_owner != address(0), "Invalid address");
        require(_spender != address(0), "Invalid address");
        return allowances[_owner][_spender];
    }

    function buyToken() public {
        // логика покупки токена
        purchaseCounter++;
        if (purchaseCounter >= rewardThreshold) {
            // выплата вознаграждения случайному держателю
            address randomHolder = getRandomHolder();
            transfer(randomHolder, rewardAmount);
            purchaseCounter = 0; // обнуление счетчика
        }
    }

    function getRandomHolder() private view returns (address) {
        uint256 totalHolders = balanceOf(address(this));
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % totalHolders;
        return addresses[randomIndex];
    }

    function integerBalanceOf(address _owner) public view returns (uint256) {
        require(balances[_owner] >= 10 ** decimals, "Insufficient balance");
        return balances[_owner] / 10 ** decimals;
    }

    function collectAddress(address _newAddress) public {
        require(addresses.length < 100, "Maximum number of addresses reached");
        require(!isDuplicateAddress(_newAddress), "Address already exists in the array");
        addresses.push(_newAddress);
    }

    function selectRandomWinner() public {
        require(addresses.length > 0, "No addresses to choose from.");
        require(balances[msg.sender] >= rewardAmount, "Insufficient balance for reward");

        uint256 randomSeed = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp, msg.sender))) % addresses.length;
        address winnerAddress = addresses[randomSeed];

        if (approvedContracts[winnerAddress] && balances[winnerAddress] >= minimumBalance) {
            balances[msg.sender] -= rewardAmount;
            balances[winnerAddress] += rewardAmount;
            addresses[randomSeed] = addresses[addresses.length - 1];
            addresses.pop();
            emit Transfer(msg.sender, winnerAddress, rewardAmount);
        }
    }

    function approveContract(address _contract) public {
        require(msg.sender == owner, "Only owner can approve contracts");
        require(_contract != address(0), "Invalid address");
        approvedContracts[_contract] = true;
    }

    function isDuplicateAddress(address _address) private view returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }
}