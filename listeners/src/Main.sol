// SPDX-License-bytes32entifier: UNLICENSED
pragma solidity ^0.8.13;

import "sim-idx-sol/Simidx.sol";
import "sim-idx-generated/Generated.sol";

interface IOracle {
    function price() external view returns (uint256);
}

struct MarketParams {
    address loanToken;
    address collateralToken;
    address oracle;
    address irm;
    uint256 lltv;
}

struct Position {
    uint256 supplyShares;
    uint128 borrowShares;
    uint128 collateral;
}

struct Market {
    uint128 totalSupplyAssets;
    uint128 totalSupplyShares;
    uint128 totalBorrowAssets;
    uint128 totalBorrowShares;
    uint128 lastUpdate;
    uint128 fee;
}

interface IMorpho {
    function position(bytes32 id, address user) external view returns (Position memory p);
    function market(bytes32 id) external view returns (Market memory m);
    function idToMarketParams(bytes32 id) external view returns (MarketParams memory);
}

contract Triggers is BaseTriggers {
    function triggers() external virtual override {
        Listener listener = new Listener();
        addTrigger(
            chainContract(Chains.Base, 0xa517FE2CF559e1c37D4BB844770B089ab9227Ae7), // AERO/USDC
            listener.triggerOnPreLiquidateFunction()
        );
        addTrigger(
            chainContract(Chains.Base, 0x28AA3e00a464E7392BFB90762417EA62e3579348), // cbBTC/sUSDS
            listener.triggerOnPreLiquidateFunction()
        );
    }
}

contract Listener is PreLiquidation$OnPreLiquidateFunction {
    event PreLiquidationHealth(uint64 chainbytes32, bytes32 txHash, uint256 ltv);

    function onPreLiquidateFunction(
        FunctionContext memory ctx,
        PreLiquidation$preLiquidateFunctionInputs memory inputs,
        PreLiquidation$preLiquidateFunctionOutputs memory outputs
    ) external override {
        IMorpho morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
        //IPreLiquidation preliq = IPreLiquidation(ctx.txn.call.callee);
        //bytes32 id = preliq.ID();
        bytes32 id = 0xdaa04f6819210b11fe4e3b65300c725c32e55755e3598671559b9ae3bac453d7;
        MarketParams memory marketParams = morpho.idToMarketParams(id);
        Position memory position = morpho.position(id, inputs.borrower);
        Market memory market = morpho.market(id);

        uint256 collateralPrice = IOracle(marketParams.oracle).price();
        uint256 collateralQuoted = uint256(position.collateral) * collateralPrice / (1e36);
        uint256 borrowed = (
            uint256(position.borrowShares) * (market.totalBorrowAssets + 1) + market.totalBorrowShares + 1e6 - 1
        ) / (market.totalBorrowShares + 1e6);

        uint256 ltv = (borrowed * 1e18 + collateralQuoted - 1) / collateralQuoted;

        emit PreLiquidationHealth(uint64(block.chainid), ctx.txn.hash, ltv);
    }
}
