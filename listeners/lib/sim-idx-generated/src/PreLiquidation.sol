// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/sim-idx-sol/src/Triggers.sol";
import "lib/sim-idx-sol/src/Context.sol";

function PreLiquidation$Abi() pure returns (Abi memory) {
    return Abi("PreLiquidation");
}
struct PreLiquidation$idFunctionOutputs {
    bytes32 outArg0;
}

struct PreLiquidation$morphoFunctionOutputs {
    address outArg0;
}

struct PreLiquidation$MarketParams {
    address loanToken;
    address collateralToken;
    address oracle;
    address irm;
    uint256 lltv;
}

struct PreLiquidation$marketParamsFunctionOutputs {
    PreLiquidation$MarketParams outArg0;
}

struct PreLiquidation$onMorphoRepayFunctionInputs {
    uint256 repaidAssets;
    bytes callbackData;
}

struct PreLiquidation$preLiquidateFunctionInputs {
    address borrower;
    uint256 seizedAssets;
    uint256 repaidShares;
    bytes data;
}

struct PreLiquidation$preLiquidateFunctionOutputs {
    uint256 outArg0;
    uint256 outArg1;
}

struct PreLiquidation$PreLiquidationParams {
    uint256 preLltv;
    uint256 preLCF1;
    uint256 preLCF2;
    uint256 preLIF1;
    uint256 preLIF2;
    address preLiquidationOracle;
}

struct PreLiquidation$preLiquidationParamsFunctionOutputs {
    PreLiquidation$PreLiquidationParams outArg0;
}

struct PreLiquidation$PreLiquidateEventParams {
    bytes32 id;
    address liquidator;
    address borrower;
    uint256 repaidAssets;
    uint256 repaidShares;
    uint256 seizedAssets;
}

abstract contract PreLiquidation$OnPreLiquidateEvent {
    function onPreLiquidateEvent(EventContext memory ctx, PreLiquidation$PreLiquidateEventParams memory inputs) virtual external;

    function triggerOnPreLiquidateEvent() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes32(0xd5b01f148b35d6069b626af105bf8881bc2e30ee1ce3de4630903abab0ba8580),
            triggerType: TriggerType.EVENT,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onPreLiquidateEvent.selector
        });
    }
}

abstract contract PreLiquidation$OnIdFunction {
    function onIdFunction(FunctionContext memory ctx, PreLiquidation$idFunctionOutputs memory outputs) virtual external;

    function triggerOnIdFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0xb3cea217),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onIdFunction.selector
        });
    }
}

abstract contract PreLiquidation$OnMorphoFunction {
    function onMorphoFunction(FunctionContext memory ctx, PreLiquidation$morphoFunctionOutputs memory outputs) virtual external;

    function triggerOnMorphoFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0x3acb5624),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onMorphoFunction.selector
        });
    }
}

abstract contract PreLiquidation$OnMarketParamsFunction {
    function onMarketParamsFunction(FunctionContext memory ctx, PreLiquidation$marketParamsFunctionOutputs memory outputs) virtual external;

    function triggerOnMarketParamsFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0x7b9e68f2),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onMarketParamsFunction.selector
        });
    }
}

abstract contract PreLiquidation$OnOnMorphoRepayFunction {
    function onOnMorphoRepayFunction(FunctionContext memory ctx, PreLiquidation$onMorphoRepayFunctionInputs memory inputs) virtual external;

    function triggerOnOnMorphoRepayFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0x05b4591c),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onOnMorphoRepayFunction.selector
        });
    }
}

abstract contract PreLiquidation$OnPreLiquidateFunction {
    function onPreLiquidateFunction(FunctionContext memory ctx, PreLiquidation$preLiquidateFunctionInputs memory inputs, PreLiquidation$preLiquidateFunctionOutputs memory outputs) virtual external;

    function triggerOnPreLiquidateFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0x3078f50a),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onPreLiquidateFunction.selector
        });
    }
}

abstract contract PreLiquidation$OnPreLiquidationParamsFunction {
    function onPreLiquidationParamsFunction(FunctionContext memory ctx, PreLiquidation$preLiquidationParamsFunctionOutputs memory outputs) virtual external;

    function triggerOnPreLiquidationParamsFunction() view external returns (Trigger memory) {
        return Trigger({
            abiName: "PreLiquidation",
            selector: bytes4(0x1d553cee),
            triggerType: TriggerType.FUNCTION,
            listenerCodehash: address(this).codehash,
            handlerSelector: this.onPreLiquidationParamsFunction.selector
        });
    }
}

contract PreLiquidation$EmitAllEvents is
  PreLiquidation$OnPreLiquidateEvent
{
  event PreLiquidate(bytes32 id, address liquidator, address borrower, uint256 repaidAssets, uint256 repaidShares, uint256 seizedAssets);

  function onPreLiquidateEvent(EventContext memory ctx, PreLiquidation$PreLiquidateEventParams memory inputs) virtual external override {
    emit PreLiquidate(inputs.id, inputs.liquidator, inputs.borrower, inputs.repaidAssets, inputs.repaidShares, inputs.seizedAssets);
  }

  function allTriggers() view external returns (Trigger[] memory) {
    Trigger[] memory triggers = new Trigger[](1);
    triggers[0] = this.triggerOnPreLiquidateEvent();
    return triggers;
  }
}