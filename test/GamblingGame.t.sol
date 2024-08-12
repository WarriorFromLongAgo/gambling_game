// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../lib/forge-std/src/Test.sol";
import "../src/GamblingGame.sol";

contract TestERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, initialSupply);
    }
}

contract GamblingGame_test is Test {
    using SafeERC20 for IERC20;

    GamblingGame public gamblingGame;

    TestERC20 public testToken;

    address public testUser = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // 指定的测试用户地址
    address initialOwner = testUser;
    address luckyDrawer = testUser;

    function setUp() public {
//        (, address msgSender, address txOrigin) = vm.readCallers();
//        console.log("setUp msgSender ===", msgSender);
//        console.log("setUp txOrigin ===", txOrigin);

        // 添加调试信息
        console.log("setUp msg.sender ===", msg.sender);
        console.log("setUp address(this) ===", address(this));
        console.log("setUp address(testUser) ===", address(testUser));
        // 你可能需要根据实际情况调整模拟调用者
//        vm.startPrank(testUser);
        vm.startBroadcast(testUser);
        console.log("setUp msg.sender ===", msg.sender);


        testToken = new TestERC20("TestToken", "TTK", 10000000 * 1e18);
        console.log("setUp testToken ===", address(testToken));

        console.log("setUp address(testUser).balance ===", address(testUser).balance);
        console.log("setUp testToken.balanceOf(testUser) ===", testToken.balanceOf(testUser));
        console.log("setUp testToken.totalSupply() ===", testToken.totalSupply());

        gamblingGame = new GamblingGame();
        console.log("setUp gamblingGame ===", address(gamblingGame));

        gamblingGame.initialize(initialOwner, address(testToken), luckyDrawer, 32);

        // 检查合约是否成功部署
        console.log("GamblingGame end ", address(gamblingGame));

        // 清理模拟调用者
        vm.stopBroadcast();
    }

//    function testSetGameBlock() public {
//        gamblingGame.setGameBlock(64);
//        uint256 pGameBlock = gamblingGame.gameBlock();
//        console.log("pGameBlock===", pGameBlock);
//        console.log("betteToken===", address(gamblingGame.betterToken()));
//    }

    function test_createBetter() public {
        // 添加调试信息
        console.log("test_createBetter msg.sender ===", msg.sender);
        // 你可能需要根据实际情况调整模拟调用者
        vm.startPrank(testUser);
        console.log("test_createBetter msg.sender ===", msg.sender);


        console.log("balance ==================================================111");
        console.log("address(msg.sender)===", address(msg.sender));
        console.log("address(testUser)===", address(testUser));
        console.log("address(testUser).balance===", address(testUser).balance);
        console.log("testToken.balanceOf(testUser)===", testToken.balanceOf(testUser));
        console.log("gamblingGame===", address(gamblingGame));
        console.log("testToken.balanceOf(gamblingGame)===", testToken.balanceOf(address(gamblingGame)));
        console.log("balance ==================================================222");

        uint256 amount = 18888;
        testToken.approve(address(gamblingGame), amount);
        gamblingGame.createBetter(testUser, amount, 1);

        uint256 result_gameBlock = gamblingGame.gameBlock();

        (address account, uint256 value,  uint8 betterType, bool hasReward, bool isReward, uint256 rewardValue, uint256 hgmId) = gamblingGame.gussBetterMapping(1, testUser);
        console.log("gamblingGame.gussBetterMapping(1, testUser) ===", value);

        (address accountOne, uint256 valueOne, uint8 betterTypeOne, bool hasRewardOne, bool isRewardOne, uint256 rewardValueOne, uint256 hgmIdOne) = gamblingGame.gussBetterList(0);
        console.log("guessBettorList(0).account===", address(accountOne));
        console.log("guessBettorList(0).betTypeOne===", betterTypeOne);
        console.log("guessBettorList(0).valueOne===", valueOne);


        console.log("balance ==================================================111");
        console.log("address(msg.sender)===", address(msg.sender));
        console.log("address(testUser)===", address(testUser));
        console.log("address(testUser).balance===", address(testUser).balance);
        console.log("testToken.balanceOf(testUser)===", testToken.balanceOf(testUser));
        console.log("gamblingGame===", address(gamblingGame));
        console.log("testToken.balanceOf(gamblingGame)===", testToken.balanceOf(address(gamblingGame)));
        console.log("balance ==================================================222");
    }
}
