pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../../interfaces/Interactions.sol";
import "../../ocean/Ocean.sol";
import "../../adapters/Curve2PoolAdapter.sol";

contract TestCurve2PoolAdapter is Test {
    Ocean ocean;
    address wallet = 0x9b64203878F24eB0CDF55c8c6fA7D08Ba0cF77E5; // USDC/USDT whale
    address lpWallet = 0x641D99580f6cf034e1734287A9E8DaE4356641cA; // 2pool LP whale
    Curve2PoolAdapter adapter;
    address usdcAddress = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;
    address usdtAddress = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9;

    function setUp() public {
        vm.createSelectFork("https://arb1.arbitrum.io/rpc"); // Will start on latest block by default
        vm.prank(wallet);
        ocean = new Ocean("");
        adapter = new Curve2PoolAdapter(address(ocean), 0x7f90122BF0700F9E7e1F688fe926940E8839F353); // 2pool address
    }

    function testSwap(bool toggle, uint256 amount) public {
        vm.startPrank(wallet);

        address inputAddress;
        address outputAddress;

        if (toggle) {
            inputAddress = usdcAddress;
            outputAddress = usdtAddress;
        } else {
            inputAddress = usdtAddress;
            outputAddress = usdcAddress;
        }

        // taking decimals into account
        amount = bound(amount, 1e17, IERC20(inputAddress).balanceOf(wallet) * 1e11);

        IERC20(inputAddress).approve(address(ocean), amount);

        uint256 prevInputBalance = IERC20(inputAddress).balanceOf(wallet);
        uint256 prevOutputBalance = IERC20(outputAddress).balanceOf(wallet);
        
        // TODO
        // Write the interaction code to call the ocean and perform a swap
    
        uint256 newInputBalance = IERC20(inputAddress).balanceOf(wallet);
        uint256 newOutputBalance = IERC20(outputAddress).balanceOf(wallet);

        assertLt(newInputBalance, prevInputBalance);
        assertGt(newOutputBalance, prevOutputBalance);

        vm.stopPrank();
    }

    function testDeposit(bool toggle, uint256 amount) public {
        vm.startPrank(wallet);

        address inputAddress;

        if (toggle) {
            inputAddress = usdcAddress;
        } else {
            inputAddress = usdtAddress;
        }

        // taking decimals into account
        amount = bound(amount, 1e17, IERC20(inputAddress).balanceOf(wallet) * 1e11);

        address outputAddress = adapter.primitive();

        IERC20(inputAddress).approve(address(ocean), amount);

        uint256 prevInputBalance = IERC20(inputAddress).balanceOf(wallet);
        uint256 prevOutputBalance = IERC20(outputAddress).balanceOf(wallet);
        
        // TODO
        // Write the interaction code to call the ocean and deposit the underlying to the curve pool
    
        uint256 newInputBalance = IERC20(inputAddress).balanceOf(wallet);
        uint256 newOutputBalance = IERC20(outputAddress).balanceOf(wallet);

        assertLt(newInputBalance, prevInputBalance);
        assertGt(newOutputBalance, prevOutputBalance);

        vm.stopPrank();
    }

    function testWithdraw(bool toggle, uint256 amount) public {
        vm.prank(wallet);

        address outputAddress;

        if (toggle) {
            outputAddress = usdcAddress;
        } else {
            outputAddress = usdtAddress;
        }

        address inputAddress = adapter.primitive();

        amount = bound(amount, 1e17, IERC20(inputAddress).balanceOf(lpWallet));

        vm.prank(lpWallet);
        IERC20(inputAddress).approve(address(ocean), amount);

        uint256 prevInputBalance = IERC20(inputAddress).balanceOf(lpWallet);
        uint256 prevOutputBalance = IERC20(outputAddress).balanceOf(lpWallet);

            // TODO
        // Write the interaction code to call the ocean and withdraw the underlying to the curve pool

        uint256 newInputBalance = IERC20(inputAddress).balanceOf(lpWallet);
        uint256 newOutputBalance = IERC20(outputAddress).balanceOf(lpWallet);

        assertLt(newInputBalance, prevInputBalance);
        assertGt(newOutputBalance, prevOutputBalance);
    }

    function _calculateOceanId(address tokenAddress) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(tokenAddress, uint256(0))));
    }

    function _fetchInteractionId(address token, uint256 interactionType) internal pure returns (bytes32) {
        uint256 packedValue = uint256(uint160(token));
        packedValue |= interactionType << 248;
        return bytes32(abi.encode(packedValue));
    }
}
