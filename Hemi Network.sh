#!/bin/bash

# 功能：备份地址文件
backup_address() {
    ADDRESS_FILE="$HOME/popm-address.json"
    BACKUP_FILE="$HOME/popm-address.json.bak"

    echo "备份 address.json 文件..."
    if [ -f "$ADDRESS_FILE" ]; then
        cp "$ADDRESS_FILE" "$BACKUP_FILE"
        echo "备份完成：$BACKUP_FILE"
    else
        echo "未找到 address.json 文件，无法备份。"
    fi
}

# 功能：下载并设置 Heminetwork
download_and_setup() {
    URL="https://github.com/hemilabs/heminetwork/releases/download/v0.4.5/heminetwork_v0.4.5_linux_amd64.tar.gz"
    FILENAME="heminetwork_v0.4.5_linux_amd64.tar.gz"
    DIRECTORY="/root/heminetwork_v0.4.4_linux_amd64"

    echo "正在下载新版本 $FILENAME..."
    wget -q "$URL" -O "$FILENAME"
    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。"
        exit 1
    fi

    echo "删除旧版本目录..."
    rm -rf "$DIRECTORY"

    echo "正在解压新版本..."
    tar -xzf "$FILENAME" -C /root
    if [ $? -eq 0 ]; then
        echo "解压完成。"
    else
        echo "解压失败。"
        exit 1
    fi

    echo "删除压缩文件..."
    rm -rf "$FILENAME"

    echo "版本安装完成！"
    echo "按任意键返回主菜单..."
    read -n 1 -s
}

# 功能：升级 Heminetwork 到最新版本
upgrade_version() {
    URL="https://github.com/hemilabs/heminetwork/releases/download/v0.4.5/heminetwork_v0.4.5_linux_amd64.tar.gz"
    FILENAME="heminetwork_v0.4.5_linux_amd64.tar.gz"
    DIRECTORY="/root/heminetwork_v0.4.4_linux_amd64"
    ADDRESS_FILE="$HOME/popm-address.json"
    BACKUP_FILE="$HOME/popm-address.json.bak"

    echo "备份 address.json 文件..."
    if [ -f "$ADDRESS_FILE" ]; then
        cp "$ADDRESS_FILE" "$BACKUP_FILE"
        echo "备份完成：$BACKUP_FILE"
    else
        echo "未找到 address.json 文件，无法备份。"
    fi

    echo "正在下载新版本 $FILENAME..."
    wget -q "$URL" -O "$FILENAME"

    if [ $? -eq 0 ]; then
        echo "下载完成。"
    else
        echo "下载失败。"
        exit 1
    fi

    echo "删除旧版本目录..."
    rm -rf "$DIRECTORY"

    echo "正在解压新版本..."
    tar -xzf "$FILENAME" -C /root

    if [ $? -eq 0 ]; then
        echo "解压完成。"
    else
        echo "解压失败。"
        exit 1
    fi

    echo "删除压缩文件..."
    rm -rf "$FILENAME"

    # 恢复 address.json 文件
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$ADDRESS_FILE"
        echo "恢复 address.json 文件：$ADDRESS_FILE"
    else
        echo "备份文件不存在，无法恢复。"
    fi

    echo "版本升级完成！"
    echo "按任意键返回主菜单栏..."
    read -n 1 -s
}

# 功能：配置环境并显示钱包信息
setup_environment() {
    echo "配置环境..."
    sudo apt update && sudo apt install screen
    echo "环境配置完成。"

    # 显示钱包信息
    ADDRESS_FILE="$HOME/popm-address.json"
    if [ -f "$ADDRESS_FILE" ]; then
        echo "读取钱包信息："
        ethereum_address=$(jq -r '.ethereum_address' "$ADDRESS_FILE")
        network=$(jq -r '.network' "$ADDRESS_FILE")
        private_key=$(jq -r '.private_key' "$ADDRESS_FILE")
        public_key=$(jq -r '.public_key' "$ADDRESS_FILE")
        pubkey_hash=$(jq -r '.pubkey_hash' "$ADDRESS_FILE")

        echo "Ethereum 地址: $ethereum_address"
        echo "网络: $network"
        echo "私钥: $private_key"
        echo "公钥: $public_key"
        echo "公钥哈希: $pubkey_hash"
    else
        echo "未找到钱包信息文件：$ADDRESS_FILE"
    fi
}

# 功能：启动 popmd
start_popmd() {
    echo "启动 popmd..."
    screen -dmS popmd ./popmd
    echo "popmd 已在 screen 中启动。"
}

# 功能：查看日志
view_logs() {
    echo "正在查看日志..."
    screen -r popmd
}

# 功能：卸载 Heminetwork
uninstall_heminetwork() {
    echo "正在卸载 Heminetwork..."
    rm -rf /root/heminetwork*
    echo "Heminetwork 已卸载。"
}

# 功能：修改地址信息并保存到 JSON 文件
modify_address_info() {
    ADDRESS_FILE="$HOME/popm-address.json"

    # 提示用户输入信息
    read -p "请输入以太坊地址: " ethereum_address
    read -p "请输入网络 (testnet/mainnet): " network
    read -p "请输入私钥: " private_key
    read -p "请输入公钥: " public_key
    read -p "请输入公钥哈希: " pubkey_hash

    # 创建新的 JSON 文件内容
    cat > "$ADDRESS_FILE" << EOL
{
  "ethereum_address": "$ethereum_address",
  "network": "$network",
  "private_key": "$private_key",
  "public_key": "$public_key",
  "pubkey_hash": "$pubkey_hash"
}
EOL

    echo "地址信息已保存到 $ADDRESS_FILE"
    cat "$ADDRESS_FILE"  # 输出保存的文件内容
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo "===== Heminetwork 管理菜单 ====="
        echo "1. 安装并设置 Heminetwork"
        echo "2. 配置环境并显示钱包信息"
        echo "3. 启动 popmd"
        echo "4. 查看日志（使用 Ctrl + A + D 退出）"
        echo "5. 备份地址信息"
        echo "6. 升级 Heminetwork"
        echo "7. 修改地址信息"
        echo "8. 卸载 Heminetwork"
        echo "9. 退出"
        echo "==============================="
        echo "脚本作者: K2 节点教程分享"
        echo "关注推特: https://x.com/BtcK241918"
        echo "==============================="
        echo "请选择操作:"

        read -p "请输入选项 (1-9): " choice

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
                upgrade_version
                ;;
            7)
                modify_address_info
                ;;
            8)
                uninstall_heminetwork
                ;;
            9)
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
