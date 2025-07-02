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

struct PreLiquidationParams {
    uint256 preLltv;
    uint256 preLCF1;
    uint256 preLCF2;
    uint256 preLIF1;
    uint256 preLIF2;
    address preLiquidationOracle;
}

interface IPreLiquidation {
    function MORPHO() external view returns (IMorpho);

    function ID() external view returns (bytes32);

    function marketParams() external returns (MarketParams memory);

    function preLiquidationParams() external view returns (PreLiquidationParams memory);

    function preLiquidate(address borrower, uint256 seizedAssets, uint256 repaidShares, bytes calldata data)
        external
        returns (uint256, uint256);
}

interface IIrm {
    /// @notice Returns the borrow rate per second (scaled by WAD) of the market `marketParams`.
    /// @dev Assumes that `market` corresponds to `marketParams`.
    function borrowRate(MarketParams memory marketParams, Market memory market) external returns (uint256);

    /// @notice Returns the borrow rate per second (scaled by WAD) of the market `marketParams` without modifying any
    /// storage.
    /// @dev Assumes that `market` corresponds to `marketParams`.
    function borrowRateView(MarketParams memory marketParams, Market memory market) external view returns (uint256);
}

contract Triggers is BaseTriggers {
    function triggers() external virtual override {
        Listener listener = new Listener();
        addTrigger(chainAbi(Chains.Base, PreLiquidation$Abi()), listener.triggerOnPreLiquidateFunction());
    }
}

contract Listener is PreLiquidation$OnPreLiquidateFunction {
    event PreLiquidationHealth(uint64 chainbytes32, bytes32 txHash, uint256 ltv);

    function wTaylorCompounded(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 WAD = 1e18;
        uint256 firstTerm = x * n;
        uint256 secondTerm = firstTerm * firstTerm / (2 * WAD);
        uint256 thirdTerm = secondTerm * firstTerm / (3 * WAD);

        return firstTerm + secondTerm + thirdTerm;
    }

    function onPreLiquidateFunction(
        FunctionContext memory ctx,
        PreLiquidation$preLiquidateFunctionInputs memory inputs,
        PreLiquidation$preLiquidateFunctionOutputs memory outputs
    ) external override {
        IMorpho morpho = IMorpho(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
        IPreLiquidation preliq = IPreLiquidation(ctx.txn.call.callee);
        bytes32 id = preliq.ID();
        MarketParams memory marketParams = morpho.idToMarketParams(id);
        Position memory position = morpho.position(id, inputs.borrower);
        Market memory market = morpho.market(id);
        uint256 interest;
        {
            uint256 elapsed = block.timestamp - market.lastUpdate;
            uint256 borrowRate = IIrm(marketParams.irm).borrowRateView(marketParams, market);
            uint256 compoundedRate = wTaylorCompounded(borrowRate, elapsed);
            interest = market.totalBorrowAssets * compoundedRate / (1e18);
        }

        uint256 collateralPrice = IOracle(marketParams.oracle).price();
        uint256 collateralQuoted = uint256(position.collateral + outputs.outArg0) * collateralPrice / (1e36);
        uint256 borrowed = (
            uint256(position.borrowShares) * (market.totalBorrowAssets + interest + 1) + market.totalBorrowShares + 1e6
                - 1
        ) / (market.totalBorrowShares + 1e6) + outputs.outArg1;

        uint256 ltv = (borrowed * 1e18 + collateralQuoted - 1) / collateralQuoted;

        emit PreLiquidationHealth(uint64(block.chainid), ctx.txn.hash, ltv);
    }
}
