// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IGamblingGame {
    // 设置 token
    function setToken(address input_tokenAddress, uint256 input_tokenDecimal) external;
    // 设置游戏块
    function setGameBlock(uint256 input_GameBlock) external;
    // 获取余额
    function getBalance() external view returns (uint256);
    // 创建一次下注
    function createBetter(address from, uint256 input_betterAmount, uint8 input_betterType) external returns (bool);
    // 开奖
    function luckyDraw(uint256[2] memory threeNumberArr) external returns (bool);
}
