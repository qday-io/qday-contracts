# 部署说明

## 环境变量配置

在项目根目录创建 `.env` 文件，包含以下配置：

```bash
# 部署配置
PRIVATE_KEY=0xyour_private_key_here_with_0x_prefix
ADMIN_ADDRESS=0x... # 可选，默认为部署者地址
INITIAL_SUPPLY=0 # 初始供应量，默认为0
VERIFY_CONTRACT=true # 是否验证合约

# 网络 RPC URLs
ETH_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your_api_key_here

# Gas 配置
GAS_PRICE=20000000000 # 20 gwei (可选，脚本会自动设置默认值)
GAS_LIMIT=5000000 # Gas 限制 (可选)

# 区块浏览器 API Keys (用于合约验证)
ETHERSCAN_API_KEY=your_etherscan_api_key

# 其他配置
REPORT_GAS=true # 是否报告 Gas 使用情况
```

## 部署命令

### 0. 配置环境变量（必需）

在运行任何部署命令之前，请确保已正确配置环境变量：

```bash
# 复制示例文件
cp env-example .env

# 编辑 .env 文件，设置必要的变量
# 至少需要设置：
# - PRIVATE_KEY: 你的私钥
# - ETH_RPC_URL: Ethereum 主网 RPC URL
```

### 1. 本地测试网络部署

**步骤 1: 启动本地 Anvil 节点**
```bash
# 启动 Anvil 节点（在第一个终端）
make anvil
```

**步骤 2: 部署合约**
```bash
# 在另一个终端部署合约
make deploy-local
```

或者直接使用 forge 命令：
```bash
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### 2. Ethereum 主网部署
```bash
forge script script/Deploy.s.sol --rpc-url $ETH_RPC_URL --broadcast --verify
```

### 3. 使用 Makefile 简化命令
```bash
# 启动本地节点
make anvil

# 本地部署
make deploy-local

# 主网部署
make deploy-mainnet

# 模拟部署
make dry-run

# 检查环境变量
make check-env
```

## 部署脚本功能

### Deploy.s.sol
- **网络支持**: 支持 Ethereum 主网和本地网络
- **权限验证**: 部署后自动验证部署者权限
- **部署信息输出**: 将部署信息输出到控制台
- **Gas 优化**: 支持自定义 Gas 价格和限制
- **合约验证**: 支持自动合约验证（需要配置 API Key）

### 支持的网络
- Ethereum Mainnet (Chain ID: 1)
- 本地网络 (Chain ID: 31337)
- 其他网络（使用默认配置）

## 部署后验证

部署完成后，脚本会：
1. 输出合约地址和部署信息到控制台
2. 验证部署者权限
3. 显示完整的部署信息
4. 提供合约验证指导

## 安全注意事项

1. **私钥安全**: 确保 `.env` 文件不被提交到版本控制系统
2. **测试网络**: 建议先在本地网络部署和测试
3. **权限管理**: 部署后及时转移管理员权限到多签钱包
4. **Gas 费用**: 主网部署前确保账户有足够的 ETH 支付 Gas 费用

## 故障排除

### 常见问题

1. **PRIVATE_KEY not set**: 检查 `.env` 文件中的私钥配置
2. **RPC URL 错误**: 确保 RPC URL 正确且可访问
3. **Gas 不足**: 增加 Gas 限制或降低 Gas 价格
4. **验证失败**: 检查 API Key 配置和网络连接

### 调试命令

```bash
# 模拟部署（不实际发送交易）
forge script script/Deploy.s.sol --rpc-url $ETH_RPC_URL

# 查看详细日志
forge script script/Deploy.s.sol --rpc-url $ETH_RPC_URL --broadcast -vvvv
``` 