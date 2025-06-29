#!/bin/bash

# Deploy.s.sol 执行脚本
# 支持本地网络和主网部署

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -l, --local     部署到本地网络 (需要先启动 anvil)"
    echo "  -m, --mainnet   部署到 Ethereum 主网"
    echo "  -s, --simulate  模拟部署 (不发送交易)"
    echo "  -v, --verify    部署后验证合约 (仅主网)"
    echo "  -h, --help      显示此帮助信息"
    echo ""
    echo "Examples:"
    echo "  $0 --local                    # 本地部署"
    echo "  $0 --mainnet                  # 主网部署"
    echo "  $0 --simulate                 # 模拟部署"
    echo "  $0 --mainnet --verify         # 主网部署并验证"
    echo ""
    echo "Environment Variables:"
    echo "  PRIVATE_KEY     部署者私钥 (必需)"
    echo "  ETH_RPC_URL     Ethereum RPC URL (主网部署时必需)"
    echo "  ETHERSCAN_API_KEY Etherscan API Key (验证时必需)"
}

# 检查环境变量
check_env() {
    print_info "检查环境变量..."
    
    # 检查 PRIVATE_KEY
    if [ -z "$PRIVATE_KEY" ]; then
        print_error "PRIVATE_KEY 未设置"
        print_info "请在 .env 文件中设置 PRIVATE_KEY"
        exit 1
    fi
    
    # 确保有 0x 前缀
    if [[ $PRIVATE_KEY != 0x* ]]; then
        PRIVATE_KEY="0x$PRIVATE_KEY"
        print_warning "检测到 PRIVATE_KEY 缺少 0x 前缀，已自动添加"
    fi
    
    print_success "PRIVATE_KEY: 已设置"
    
    # 检查 ETH_RPC_URL (主网部署时)
    if [ "$1" = "mainnet" ] || [ "$1" = "simulate" ]; then
        if [ -z "$ETH_RPC_URL" ]; then
            print_error "ETH_RPC_URL 未设置"
            print_info "请在 .env 文件中设置 ETH_RPC_URL"
            exit 1
        fi
        print_success "ETH_RPC_URL: 已设置"
    fi
    
    # 检查 ETHERSCAN_API_KEY (验证时)
    if [ "$2" = "verify" ]; then
        if [ -z "$ETHERSCAN_API_KEY" ]; then
            print_warning "ETHERSCAN_API_KEY 未设置，将跳过合约验证"
        else
            print_success "ETHERSCAN_API_KEY: 已设置"
        fi
    fi
}

# 加载 .env 文件
load_env() {
    if [ -f ".env" ]; then
        print_info "加载 .env 文件..."
        export $(grep -v '^#' .env | xargs)
        print_success ".env 文件已加载"
    else
        print_warning ".env 文件不存在"
    fi
}

# 本地部署
deploy_local() {
    # 如果 out.txt 存在则先删除
    if [ -f out.txt ]; then
        rm out.txt
    fi
    print_info "开始本地部署..."
    
    # 检查 anvil 是否运行
    if ! curl -s http://localhost:8545 > /dev/null 2>&1; then
        print_error "本地节点未运行"
        print_info "请先启动 anvil: anvil --account 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80,1000000000000000000000"
        exit 1
    fi
    
    print_info "执行部署脚本..."
    print_info "部署信息将保存到 out.txt 文件中..."
    
    # 记录部署开始时间
    echo "=== 本地部署开始时间: $(date) ===" | tee out.txt
    
    # 执行部署并同时输出到控制台和文件
    forge script script/Deploy.s.sol \
        --rpc-url http://localhost:8545 \
        --broadcast \
        -vvv 2>&1 | tee -a out.txt
    
    # 记录部署完成时间
    echo "=== 本地部署完成时间: $(date) ===" | tee -a out.txt
    
    print_success "本地部署完成！"
    print_success "部署信息已保存到 out.txt 文件中"
}

# 主网部署
deploy_mainnet() {
    # 如果 out.txt 存在则先删除
    if [ -f out.txt ]; then
        rm out.txt
    fi
    print_info "开始主网部署..."
    
    # 确认部署
    read -p "确认要部署到 Ethereum 主网吗? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "部署已取消"
        exit 0
    fi
    
    print_info "执行部署脚本..."
    print_info "部署信息将保存到 out.txt 文件中..."
    
    # 记录部署开始时间
    echo "=== 主网部署开始时间: $(date) ===" | tee out.txt
    
    if [ "$1" = "verify" ]; then
        forge script script/Deploy.s.sol \
            --rpc-url "$ETH_RPC_URL" \
            --broadcast \
            --verify \
            -vvv 2>&1 | tee -a out.txt
    else
        forge script script/Deploy.s.sol \
            --rpc-url "$ETH_RPC_URL" \
            --broadcast \
            -vvv 2>&1 | tee -a out.txt
    fi
    
    # 记录部署完成时间
    echo "=== 主网部署完成时间: $(date) ===" | tee -a out.txt
    
    print_success "主网部署完成！"
    print_success "部署信息已保存到 out.txt 文件中"
}

# 模拟部署
simulate_deploy() {
    # 如果 out.txt 存在则先删除
    if [ -f out.txt ]; then
        rm out.txt
    fi
    print_info "开始模拟部署..."
    
    print_info "执行部署脚本 (模拟模式)..."
    print_info "部署信息将保存到 out.txt 文件中..."
    
    # 记录部署开始时间
    echo "=== 模拟部署开始时间: $(date) ===" | tee out.txt
    
    forge script script/Deploy.s.sol \
        --rpc-url "$ETH_RPC_URL" \
        -vvv 2>&1 | tee -a out.txt
    
    # 记录部署完成时间
    echo "=== 模拟部署完成时间: $(date) ===" | tee -a out.txt
    
    print_success "模拟部署完成！"
    print_success "部署信息已保存到 out.txt 文件中"
}

# 主函数
main() {
    print_info "=== Deploy.s.sol 部署脚本 ==="
    
    # 加载环境变量
    load_env
    
    # 解析命令行参数
    local deploy_type=""
    local verify_flag=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -l|--local)
                deploy_type="local"
                shift
                ;;
            -m|--mainnet)
                deploy_type="mainnet"
                shift
                ;;
            -s|--simulate)
                deploy_type="simulate"
                shift
                ;;
            -v|--verify)
                verify_flag="verify"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定部署类型，显示帮助
    if [ -z "$deploy_type" ]; then
        print_error "请指定部署类型"
        show_help
        exit 1
    fi
    
    # 检查环境变量
    check_env "$deploy_type" "$verify_flag"
    
    # 执行部署
    case $deploy_type in
        local)
            deploy_local
            ;;
        mainnet)
            deploy_mainnet "$verify_flag"
            ;;
        simulate)
            simulate_deploy
            ;;
    esac
}

# 运行主函数
main "$@" 