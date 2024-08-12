// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {TransparentUpgradeableProxy} from "../../../lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract GamblingGameProxy is TransparentUpgradeableProxy {

    constructor(address input_BridgeLogic, address input_admin, bytes memory input_data)
            TransparentUpgradeableProxy(input_BridgeLogic, input_admin, input_data){
    }

    receive() external payable {}

}
