// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Listener} from "../src/Main.sol";
import "sim-idx-sol/Simidx.sol";
import "sim-idx-generated/Generated.sol";
import {MockContexts} from "sim-idx-sol/test/MockContexts.sol";

contract ListenerTest is Test {
    Listener public listener;

    function setUp() public {
        listener = new Listener();
        vm.recordLogs();
    }
}
