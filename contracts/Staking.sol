// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Staking is ReentrancyGuard {

    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastUpdate;

    uint256 public rewardPerBlock = 1e14;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    function stake() external payable {
        require(msg.value > 0, "Amount must be greater than zero");

        balances[msg.sender] += msg.value;
        lastUpdate[msg.sender] = block.number;

        emit Staked(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawn(msg.sender, amount);
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 blocksPassed = block.number - lastUpdate[user];
        return blocksPassed * rewardPerBlock * balances[user] / 1e18;
    }

    function claimReward() external nonReentrant {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0, "No reward available");

        lastUpdate[msg.sender] = block.number;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(msg.sender, reward);
    }
}
