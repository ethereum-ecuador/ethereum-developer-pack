// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    struct User {
        string _username;
        string _country;
        AccountStatus _status;
    }

    address private _owner;
    mapping(address => uint256) private _balances;
    mapping(address => User) public _accounts;
    mapping(address => bool) public _accountsCreated;

    address[5] _admins;

    enum AccountStatus {
        ACTIVE,
        INACTIVE,
        FROZEN,
        OVERDUE,
        IN_DEBT,
        ELIGIBLE_FOR_LOANS
    }

    // Despliegue del contrato
    constructor() {
        _owner = msg.sender;
    }

    function createAccount(string calldata username, string calldata country)
        public
        onlyNewAccount
    {
        _accounts[msg.sender] = User({
            _username: username,
            _country: country,
            _status: AccountStatus.ACTIVE
        });
        _accountsCreated[msg.sender] = true;
    }

    modifier onlyNewAccount() {
        require(!_accountsCreated[msg.sender], "Account is already created");
        _;
    }

    // Cualquier usuario pude ver su balance
    function getBalance() public view returns (uint256) {
        return _balances[msg.sender];
    }

    // Solo los usuarios autorizados podran ver los balances de todas las cuentas
    function getUserBalance(address account)
        public
        view
        onlyBankAdmins
        returns (uint256)
    {
        return _balances[account];
    }

    modifier onlyBankAdmins() {
        // Validar que la direccion este dentro del array admins[]
        // require(msg.sender in _admins, "Unauthorized");
        _;
    }

    function addAdmin() public onlyBankOwner{
        // Logica de añadir admins
        // admins.push(msg.sender)
    }

    modifier onlyBankOwner() {
        require(msg.sender == _owner, "Unauthorized");
        _;
    }

    // Transferir Ethers al Smart Contract. Sumar un valor interno a la cuenta a depositar (No Ethers)
    function deposit(address to) public payable {
        _balances[to] += msg.value;
    }

    // Transferencia de dinero digital (Logica dentro del smart contract)
    function transfer(uint256 value, address to) public hasFounds(value) {
        _balances[msg.sender] -= value;
        _balances[to] += value;
    }

    // Verificar que tiene fondos antes de realizar tranfsferencias
    modifier hasFounds(uint256 value) {
        require(_balances[msg.sender] >= value, "Fondos insuficientes");
        _;
    }

    // Retirar fondos. Transferir Ethers desde el contrato a la cuenta
    function withdraw(uint256 amount) public hasFounds(amount) {
        _balances[msg.sender] -= amount;
        address payable receiver = payable(msg.sender);
        receiver.transfer(amount);
    }
}
