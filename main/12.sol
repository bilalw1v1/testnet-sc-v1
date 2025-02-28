// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NativeTokenFaucet {
    address public owner;
    uint256 public claimAmount = 0.1 ether; // کتنے ٹوکن دینے ہیں؟
    mapping(address => uint256) public lastClaimTime;
    uint256 public cooldownTime = 1 days; // 24 گھنٹے بعد دوبارہ کلیم کر سکتے ہیں

    event TokensClaimed(address indexed user, uint256 amount, uint256 timestamp);
    event FaucetFunded(address indexed sender, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 🚀 فنڈز بھیجنے کے لیے نیا فنکشن تاکہ یوزرز کے والٹ سے ٹوکن نہ جائیں
    function fundFaucet() public payable {
        require(msg.value > 0, "Send some native tokens");
        emit FaucetFunded(msg.sender, msg.value);
    }

    receive() external payable {}

    // ✅ ایک یوزر کے لیے ٹوکن کلیم فنکشن
    function claimTokens(address user) external {
        require(user != address(0), "Invalid address");
        require(address(this).balance >= claimAmount, "Faucet empty");
        require(block.timestamp - lastClaimTime[user] >= cooldownTime, "Wait 24 hours to claim again");

        lastClaimTime[user] = block.timestamp;
        payable(user).transfer(claimAmount);

        emit TokensClaimed(user, claimAmount, block.timestamp);
    }

    // ✅ Multiple Addresses کو ایک ساتھ ٹوکن بھیجنے کا فنکشن
    function batchClaimTokens(address[] memory users) external {
        uint256 numUsers = users.length;
        require(numUsers > 0, "No addresses provided");

        for (uint256 i = 0; i < numUsers; i++) {
            address user = users[i];

            require(user != address(0), "Invalid address");
            require(address(this).balance >= claimAmount, "Faucet empty");
            require(block.timestamp - lastClaimTime[user] >= cooldownTime, "Wait before claiming again");

            lastClaimTime[user] = block.timestamp;
            payable(user).transfer(claimAmount);
        }
    }

    // ✅ Faucet کے بیلنس کو چیک کرنا
    function getFaucetBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ✅ Withdraw function اگر owner فنڈز نکالنا چاہے
    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Not enough balance");
        payable(owner).transfer(amount);
    }
}