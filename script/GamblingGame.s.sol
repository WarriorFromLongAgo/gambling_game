// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Script, console} from "../lib/forge-std/src/Script.sol";
import "../src/access/proxy/GamblingGameProxy.sol";
import "../src/GamblingGame.sol";

contract TestERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract GamblingGame_script is Script {
    GamblingGame public gamblingGame;

    GamblingGameProxy public proxyGamblingGame;

    TestERC20 public testToken;

    function setUp() public {
        console.log("setUp ===============================");

    }

    function run() public {
        console.log("run ===============================");

        vm.startBroadcast();

        address admin = msg.sender;

        testToken = new TestERC20("TestToken", "TTK", 10000000 * 1e18);
        gamblingGame = new GamblingGame();
        proxyGamblingGame = new GamblingGameProxy(address(gamblingGame), admin, "");

        GamblingGame(address(proxyGamblingGame)).initialize(admin, address(testToken), admin, 32);

        console.log("testToken::", address(testToken));
        console.log("gamblingGame:::", address(gamblingGame));
        console.log("proxyGamblingGame::", address(proxyGamblingGame));

        vm.stopBroadcast();
    }
}
