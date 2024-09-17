#!/bin/bash

# 发生错误时退出脚本
set -e

# 捕获错误并提示
trap 'echo "发生错误，脚本已退出。";' ERR

# 功能：自动安装缺少的依赖项 (git 和 make)
install_dependencies() {
    for cmd in git make; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd 未安装，正在安装..."

            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                sudo apt update && sudo apt install -y $cmd
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                brew install $cmd
            else
                echo "不支持的操作系统，请手动安装 $cmd。"
                exit 1
            fi
        fi
    done
    echo "依赖项安装完成。"
}

# 功能：检查 Go 版本是否 >= 1.22.2
check_go_version() {
    if command -v go >/dev/null 2>&1; then
        CURRENT_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
        MINIMUM_GO_VERSION="1.22.2"

        if [ "$(printf '%s\n' "$MINIMUM_GO_VERSION" "$CURRENT_GO_VERSION" | sort -V | head -n1)" = "$MINIMUM_GO_VERSION" ]; then
            echo "Go 版本满足要求: $CURRENT_GO_VERSION"
        else
            echo "当前 Go 版本 ($CURRENT_GO_VERSION) 低于要求，安装最新的 Go。"
            install_go
        fi
    else
        echo "未检测到 Go，正在安装 Go。"
        install_go
    fi
}

install_go() {
    wget https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    echo "Go 安装完成，版本: $(go version)"
}

# 功能1：下载、解压缩并生成地址信息
download_and_setup() {
    wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.3/heminetwork_v0.4.3_linux_amd64.tar.gz -O heminetwork_v0.4.3_linux_amd64.tar.gz

    TARGET_DIR="$HOME/heminetwork"
    mkdir -p "$TARGET_DIR"

    tar -xvf heminetwork_v0.4.3_linux_amd64.tar.gz -C "$TARGET_DIR"

    mv "$TARGET_DIR/heminetwork_v0.4.3_linux_amd64/"* "$TARGET_DIR/"
    rmdir "$TARGET_DIR/heminetwork_v0.4.3_linux_amd64"

    cd "$TARGET_DIR"
    ./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json

    echo "地址文件生成成功。"
}

# 功能2：设置环境变量
setup_environment() {
    if [[ ! -f ~/popm-address.json ]]; then
        echo "地址文件不存在，请先生成地址文件。"
        exit 1
    fi

    cd "$HOME/heminetwork"
    cat ~/popm-address.json

    POPM_BTC_PRIVKEY=$(jq -r '.private_key' ~/popm-address.json)
    read -p "输入 sats/vB 值: " POPM_STATIC_FEE

    export POPM_BTC_PRIVKEY=$POPM_BTC_PRIVKEY
    export POPM_STATIC_FEE=$POPM_STATIC_FEE
    export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public

    echo "环境变量已设置。"
}

# 功能3：启动 popmd（使用 nohup）
start_popmd() {
    cd "$HOME/heminetwork"
    nohup ./popmd > popmd.log 2>&1 &
    echo "popmd 已启动，日志保存在 popmd.log 中。"
}

# 功能4：查看日志
view_logs() {
    cd "$HOME/heminetwork"
    tail -f popmd.log
}

# 功能5：备份地址信息
backup_address() {
    if [[ -f ~/popm-address.json ]]; then
        echo "请保存以下地址文件信息："
        cat ~/popm-address.json
    else
        echo "地址文件不存在。"
    fi
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo "===== Heminetwork 管理菜单 ====="
        echo "1. 安装并设置 Heminetwork"
        echo "2. 配置环境"
        echo "3. 启动 popmd"
        echo "4. 查看日志"
        echo "5. 备份地址信息"
        echo "6. 退出"
        echo "==============================="
        echo "脚本作者: K2 节点教程分享"
        echo "关注推特: https://x.com/BtcK241918"
        echo "==============================="
        echo "请选择操作:"

        read -p "请输入选项 (1-6): " choice

        case $choice in
            1)
                download_and_setup
                ;;
            2)
                setup_environment
                ;;
            3)
                start_popmd
                ;;
            4)
                view_logs
                ;;
            5)
                backup_address
                ;;
            6)
                echo "退出脚本。"
                exit 0
                ;;
            *)
                echo "无效选项，请重新输入。"
                ;;
        esac
    done
}

# 启动主菜单
echo "准备启动主菜单..."
main_menu
