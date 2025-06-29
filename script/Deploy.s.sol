// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/wAbel.sol";

contract DeployScript is Script {
    // 网络配置
    struct NetworkConfig {
        string name;
        uint256 chainId;
        string rpcUrl;
        string explorerUrl;
        uint256 gasPrice;
        uint256 gasLimit;
    }

    // 部署配置
    struct DeployConfig {
        address deployer;
        address admin;
        uint256 initialSupply;
        bool verify;
    }

    function setUp() public {}

    function run() public {
        // 获取部署配置
        DeployConfig memory config = getDeployConfig();
        
        // 获取网络配置
        NetworkConfig memory network = getNetworkConfig();
        
        console2.log("=== Deployment Config ===");
        console2.log("Network:", network.name);
        console2.log("Chain ID:", network.chainId);
        console2.log("Deployer address:", config.deployer);
        console2.log("Admin address:", config.admin);
        console2.log("Initial supply:", config.initialSupply);
        console2.log("Verify contract:", config.verify);
        console2.log("========================");

        // 获取私钥
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // 开始广播
        vm.startBroadcast(deployerPrivateKey);

        // 部署 wAbel 合约
        console2.log("Deploying wAbel contract...");
        wAbel token = new wAbel();
        console2.log("wAbel contract deployed at:", address(token));
        console2.log("Contract name:", token.name());
        console2.log("Contract symbol:", token.symbol());

        // 验证部署者权限
        require(token.hasRole(token.DEFAULT_ADMIN_ROLE(), config.deployer), "Deployer does not have default admin role");
        require(token.hasRole(token.ADMIN_ROLE(), config.deployer), "Deployer does not have admin role");

        // 如果需要验证合约
        if (config.verify && bytes(network.explorerUrl).length > 0) {
            console2.log("Waiting for block confirmation for contract verification...");
            // 这里可以添加验证逻辑
        }

        vm.stopBroadcast();

        // 输出部署信息
        console2.log("=== Deployment Complete ===");
        console2.log("Contract address:", address(token));
        console2.log("Deployer:", config.deployer);
        console2.log("Admin:", config.admin);
        console2.log("Network:", network.name);
        console2.log("==========================");

        // 保存部署信息到文件
        saveDeploymentInfo(address(token), network, config);
    }

    function getDeployConfig() internal view returns (DeployConfig memory) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // 可以从环境变量获取管理员地址，默认为部署者
        address admin = vm.envOr("ADMIN_ADDRESS", deployer);
        
        // 初始供应量，默认为 0
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(0));
        
        // 是否验证合约
        bool verify = vm.envOr("VERIFY_CONTRACT", true);
        
        return DeployConfig({
            deployer: deployer,
            admin: admin,
            initialSupply: initialSupply,
            verify: verify
        });
    }

    function getNetworkConfig() internal view returns (NetworkConfig memory) {       

        uint256 chainId= block.chainid;

        if (chainId==97) {
        return NetworkConfig({
            name: "Qday Testnet",
            chainId: block.chainid,
            rpcUrl: vm.envString("ETH_RPC_URL"),
            explorerUrl: "",
            gasPrice: vm.envOr("GAS_PRICE", uint256(20 gwei)),
            gasLimit: vm.envOr("GAS_LIMIT", uint256(5000000))
        });
        }else {
        return NetworkConfig({
            name: "Qday Mainnet",
            chainId: block.chainid,
            rpcUrl: vm.envString("ETH_RPC_URL"),
            explorerUrl: "",
            gasPrice: vm.envOr("GAS_PRICE", uint256(20 gwei)),
            gasLimit: vm.envOr("GAS_LIMIT", uint256(5000000))
        });
        }


    }

    function saveDeploymentInfo(
        address tokenAddress,
        NetworkConfig memory network,
        DeployConfig memory config
    ) internal {
        console2.log("=== Deployment Info ===");
        console2.log("Token Address:", tokenAddress);
        console2.log("Network:", network.name);
        console2.log("Chain ID:", network.chainId);
        console2.log("Deployer:", config.deployer);
        console2.log("Admin:", config.admin);
        console2.log("Deployed at:", block.timestamp);
        console2.log("Block:", block.number);
        console2.log("=======================");
        console2.log("Deployment info logged to console");
    }

    // 验证合约的函数（可选）
    function verifyContract(address contractAddress, NetworkConfig memory network) internal {
        if (bytes(network.explorerUrl).length == 0) {
            console2.log("Skipping verification: No block explorer URL configured");
            return;
        }
        
        console2.log("Please verify contract manually:");
        console2.log("Contract address:", contractAddress);
        console2.log("Block explorer:", network.explorerUrl);
        console2.log("Constructor arguments: None");
    }
} 