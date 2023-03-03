// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ScamPump is ERC20 {

    address public owner;
    address public developer;
    uint256 public maxSupply;
    uint256 public burnThreshold;
    uint256 public transactionFee;
    uint256 public initialPurchaseTime;
    bool public initialPurchaseActive;

    constructor() ERC20("ScamPump", "SCAM") {
        owner = msg.sender;
        developer = 0x10044472aDD5856dbe1ca09a4c236d382a80966B;
        maxSupply = 69000000 * 10 ** decimals();
        burnThreshold = 42000000 * 10 ** decimals();
        transactionFee = 5;
        initialPurchaseTime = block.timestamp + 60 minutes;
        initialPurchaseActive = true;

        _mint(owner, maxSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function setTransactionFee(uint256 _transactionFee) external onlyOwner {
        transactionFee = _transactionFee;
    }

    function setInitialPurchaseTime(uint256 _initialPurchaseTime) external onlyOwner {
        initialPurchaseTime = _initialPurchaseTime;
    }

    function setInitialPurchaseActive(bool _initialPurchaseActive) external onlyOwner {
        initialPurchaseActive = _initialPurchaseActive;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 fee = 0;

        if (initialPurchaseActive && msg.sender == owner && block.timestamp <= initialPurchaseTime) {
            require(amount <= balanceOf(owner), "Not enough balance for initial purchase.");

            // Allow the owner to buy during the first 60 minutes after liquidity is added
            if (recipient != owner) {
                fee = amount * transactionFee / 100;
                _transfer(owner, developer, fee);
                amount -= fee;
            }
        } else {
            require(amount <= balanceOf(msg.sender), "Not enough balance for transfer.");

            // Apply transaction fee
            fee = amount * transactionFee / 100;
            _transfer(msg.sender, developer, fee);
            amount -= fee;
        }

        // Burn 5% of tokens until we reach the burn threshold
        if (totalSupply() > burnThreshold) {
            uint256 burnAmount = amount * 5 / 100;
            amount -= burnAmount;
            _burn(msg.sender, burnAmount);
        }

        _transfer(msg.sender, recipient, amount);
        return true;
    }

}
