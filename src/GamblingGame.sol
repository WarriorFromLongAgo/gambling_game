// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../lib/forge-std/src/console.sol";

import "./interface/IGamblingGame.sol";

contract GamblingGame is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, IGamblingGame {
    using SafeERC20 for IERC20;

    enum BettorType {
        Big,
        Small,
        Single,
        Double
    }

    // 游戏结算token
    IERC20 public betterToken;
    // token 的 decimal
    uint256 public betterTokenDecimal;
    // 游戏的区块个数，作为游戏周期结算
    uint256 public gameBlock;
    // 全局的id
    uint256 public hgmGlobalId;
    // 开奖人
    address public luckyDrawer;

//    uint256 misBetterAmount = 10 ** betterTokenDecimal;

    // 每轮游戏的信息
    struct RoundGame {

        uint256 startBlock;

        uint256 endBlock;
        // 随机数
        uint256[2] threeNumberArr;
    }

    struct GussBetter {
        // 账户
        address account;
        // 投注金额
        uint256 value;
        // 下注类型
        uint8 betterType;
        // 是否中奖
        bool isReward;
        // 是否提取
        bool hasReward;
        // 奖金
        uint256 rewardValue;
        // 全局id
        uint256 hgmId;
    }
    // 下注人信息
    GussBetter[] public gussBetterList;

    // key = hgmGlobalId, value = 对局信息
    mapping(uint256 => RoundGame) public  roundGameInfo;

    // key = hgmGlobalId
    //      key = 用户地址 value = 获奖人信息
    mapping(uint256 => mapping(address => GussBetter)) public gussBetterMapping;

    // 投注者投注时创建事件
    event GuessBetCreatedEvent(
        address indexed account,
        uint256 value,
        uint8 betterType
    );

    // 投注者投注时创建事件
    event AllocateRewardEvent(
        address indexed account,
        uint256 hgmId,
        uint8 betterType,
    // 是否提取
        bool hasReward,
    // 奖金
        uint256 rewardValue
    );

    modifier onlyLuckyDrawer() {
        require(luckyDrawer == msg.sender, "caller must be luckyDrawer");
        _;
    }

    constructor(){
//        _disableInitializers();
    }

    function initialize(address initOwner, address initToken, address initLuckyDrawer, uint256 initGameBlock) public initializer {
        __Ownable_init(initOwner);
        console.log("initialize __Ownable_init ");
        betterToken = IERC20(initToken);
        console.log("initialize betterToken = ", address(betterToken));
        luckyDrawer = initLuckyDrawer;
        console.log("initialize luckyDrawer = ", luckyDrawer);
        console.log("initialize initOwner = ", initOwner);
        gameBlock = initGameBlock;
        hgmGlobalId = 1;

        uint256[2] memory fixedArray;
        roundGameInfo[hgmGlobalId] = RoundGame(block.number, (block.number + initGameBlock), fixedArray);

        console.log("initialize end");
    }

    // 设置 token
    function setToken(address input_tokenAddress, uint256 input_tokenDecimal) external onlyOwner {
        // 设置代币的数据
        betterToken = IERC20(input_tokenAddress);
        betterTokenDecimal = input_tokenDecimal;
    }

    // 设置游戏块
    function setGameBlock(uint256 input_GameBlock) external onlyOwner {
        gameBlock = input_GameBlock;
    }

    // 获取余额
    function getBalance() external view returns (uint256){
        return betterToken.balanceOf(address(this));
    }

    function getCallerAddress() public returns (address) {
        address caller = msg.sender;
        console.log("Caller address:", caller);
        return caller;
    }

    // 创建一次下注
    function createBetter(address from, uint256 input_betterAmount, uint8 input_betterType) external returns (bool){
        console.log("createBetter address(msg.sender) = ", address(msg.sender));
        console.log("createBetter address(tx.origin) = ", address(tx.origin));
        console.log("createBetter address(this) = ", address(this));
        console.log("createBetter address(from) = ", address(from));
        console.log("createBetter address(betterToken) = ", address(betterToken));
        console.log("createBetter betterToken.balanceOf(msg.sender) = ", betterToken.balanceOf(msg.sender));
        console.log("createBetter betterToken.balanceOf(from)) = ", betterToken.balanceOf(from));
        console.log("createBetter input_betterAmount = ", input_betterAmount);
        console.log("createBetter input_betterType = ", input_betterType);

        require(input_betterType >= uint8(BettorType.Big) && input_betterType <= uint8(BettorType.Double), "createBetter invalid better type");
        require(input_betterAmount >= 10 ** betterTokenDecimal, "The better amount is too small");
        require(betterToken.balanceOf(from) >= input_betterAmount, "The balance is insufficient");
        require(roundGameInfo[hgmGlobalId].endBlock >= block.number, "The game isn't over yet");

        uint256 allowance = betterToken.allowance(from, address(this));
        console.log("createBetter allowance = ", allowance);

        betterToken.safeTransferFrom(from, address(this), input_betterAmount);

        GussBetter memory gb = GussBetter({
            account: msg.sender,
            value: input_betterAmount,
            hgmId: hgmGlobalId,
            betterType: input_betterType,
            hasReward: false,
            isReward: false,
            rewardValue: 0
        });
        gussBetterList.push(gb);

        emit GuessBetCreatedEvent(msg.sender, input_betterAmount, input_betterType);

        return true;
    }

    // 开奖
    function luckyDraw(uint256[2] memory threeNumberArr) external onlyLuckyDrawer returns (bool){
        require(block.number > roundGameInfo[hgmGlobalId].endBlock, "The game isn't over yet");

        uint256 threeNumberResult = 0;
        for (uint i = 0; i < threeNumberArr.length; i++) {
            threeNumberResult += threeNumberArr[i];
        }
        require(threeNumberResult >= 28, "error data");

        for (uint i = 0; i < gussBetterList.length; i++) {
            if ((threeNumberResult >= 14 && threeNumberResult <= 27) && (gussBetterList[i].betterType == uint8(BettorType.Big))) {
                uint256 rewardValue = gussBetterList[i].value * 150 / 100;
                allocateReward(gussBetterList[i], rewardValue);
            }
            if ((threeNumberResult >= 0 && threeNumberResult <= 13) && (gussBetterList[i].betterType == uint8(BettorType.Small))) {
                uint256 rewardValue = gussBetterList[i].value * 200 / 100;
                allocateReward(gussBetterList[i], rewardValue);
            }
            if ((threeNumberResult % 2 == 0) && (gussBetterList[i].betterType == uint8(BettorType.Double))) {
                uint256 rewardValue = gussBetterList[i].value * 400 / 100;
                allocateReward(gussBetterList[i], rewardValue);
            }
            if ((threeNumberResult % 2 != 0) && (gussBetterList[i].betterType == uint8(BettorType.Single))) {
                uint256 rewardValue = gussBetterList[i].value * 200 / 100;
                allocateReward(gussBetterList[i], rewardValue);
            }
            allocateReward(gussBetterList[i], 0);
        }

        printGussBetterList();
        delete gussBetterList;

        uint256[2] memory fixedArray;
        roundGameInfo[hgmGlobalId++] = RoundGame(block.number, (block.number + roundGameInfo[hgmGlobalId].endBlock), fixedArray);

        return true;
    }

    function allocateReward(GussBetter memory input_gussBetter, uint256 input_rewardAmount) internal {
        if (input_rewardAmount > 0) {
            input_gussBetter.isReward = true;
            input_gussBetter.rewardValue = input_rewardAmount;
            betterToken.safeTransfer(input_gussBetter.account, input_rewardAmount);
            input_gussBetter.hasReward = true;
        }
        gussBetterMapping[hgmGlobalId][input_gussBetter.account] = input_gussBetter;
        emit AllocateRewardEvent(input_gussBetter.account, hgmGlobalId, input_gussBetter.betterType, true, input_rewardAmount);
    }

    function printGussBetterList() internal view {
        console.log("luckyDraw gussBetterList length = ", gussBetterList.length);
    }
}
