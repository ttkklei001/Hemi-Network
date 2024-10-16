#!/bin/bash

# 功能1：下载、解压缩并生成地址信息
download_and_setup() {
    wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.5/heminetwork_v0.4.5_linux_amd64.tar.gz -O heminetwork_v0.4.5_linux_amd64.tar.gz

    TARGET_DIR="$HOME/heminetwork"
    mkdir -p "$TARGET_DIR"

    tar -xvf heminetwork_v0.4.5_linux_amd64.tar.gz -C "$TARGET_DIR"

    mv "$TARGET_DIR/heminetwork_v0.4.5_linux_amd64/"* "$TARGET_DIR/"
    rmdir "$TARGET_DIR/heminetwork_v0.4.5_linux_amd64"

    cd "$TARGET_DIR"
    ./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json

    echo "地址文件生成成功。"
    read -p "按回车返回主菜单..." enter
}

# 功能2：设置环境变量
setup_environment() {
    echo "请选择钱包来源："
    echo "1. 使用新生成的钱包"
    echo "2. 手动输入新的钱包信息"

    read -p "请输入选项 (1-2): " wallet_choice

    case $wallet_choice in
        1)
            ADDRESS_FILE="$HOME/popm-address.json"
            if [[ ! -f "$ADDRESS_FILE" ]]; then
                echo "地址文件不存在，请先生成地址文件。"
                read -p "按回车返回主菜单..." enter
                main_menu
            fi
            ;;
        2)
            read -p "请输入以太坊地址: " MANUAL_ETH_ADDRESS
            read -p "请输入私钥: " MANUAL_PRIVATE_KEY
            read -p "请输入公钥: " MANUAL_PUBLIC_KEY
            read -p "请输入 pubkey_hash: " MANUAL_PUBKEY_HASH

            # 创建 JSON 内容并保存到文件
            echo "{
  \"ethereum_address\": \"$MANUAL_ETH_ADDRESS\",
  \"network\": \"testnet\",
  \"private_key\": \"$MANUAL_PRIVATE_KEY\",
  \"public_key\": \"$MANUAL_PUBLIC_KEY\",
  \"pubkey_hash\": \"$MANUAL_PUBKEY_HASH\"
}" > ~/popm-address.json

            ADDRESS_FILE="$HOME/popm-address.json"
            ;;
        *)
            echo "无效选项，请重新选择。"
            read -p "按回车返回主菜单..." enter
            main_menu
            ;;
    esac

    # 显示手动输入的钱包信息
    echo "您输入的钱包信息："
    cat "$ADDRESS_FILE"

    # 读取私钥
    POPM_BTC_PRIVKEY=$(jq -r '.private_key' "$ADDRESS_FILE")

    # 设置固定的网络类型
    POPM_NETWORK="testnet"

    # 提示用户输入 sats/vB 值
    read -p "输入 sats/vB 值: " POPM_STATIC_FEE

    # 设置环境变量
    export POPM_BTC_PRIVKEY=$POPM_BTC_PRIVKEY
    export POPM_STATIC_FEE=$POPM_STATIC_FEE
    export POPM_NETWORK=$POPM_NETWORK
    export POPM_BFG_URL="wss://testnet.rpc.hemi.network/v1/ws/public"

    # 显示已设置的环境变量
    echo "环境变量已设置："
    echo "POPM_BTC_PRIVKEY=$POPM_BTC_PRIVKEY"
    echo "POPM_STATIC_FEE=$POPM_STATIC_FEE"
    echo "POPM_NETWORK=$POPM_NETWORK"
    echo "POPM_BFG_URL=$POPM_BFG_URL"

    # 备份输入的钱包信息
    echo "备份您输入的钱包信息："
    echo "{
  \"ethereum_address\": \"$MANUAL_ETH_ADDRESS\",
  \"network\": \"testnet\",
  \"private_key\": \"$MANUAL_PRIVATE_KEY\",
  \"public_key\": \"$MANUAL_PUBLIC_KEY\",
  \"pubkey_hash\": \"$MANUAL_PUBKEY_HASH\"
}" > ~/manual-wallet-backup.json

    # 显示备份内容
    echo "备份的钱包信息："
    cat ~/manual-wallet-backup.json
    echo -e "\n您可以复制以上信息。"

    read -p "按回车返回主菜单..." enter
}

# 功能3：启动 popmd
start_popmd() {
    echo "启动 popmd..."
    screen -dmS popmd ./popmd
    echo "popmd 已在 screen 中启动。"
    read -p "按回车返回主菜单..." enter
}

# 功能4：查看日志
view_logs() {
    echo "正在查看日志..."
    screen -r popmd
    read -p "按回车返回主菜单..." enter
}

# 功能5：备份地址文件
backup_address() {
    ADDRESS_FILE="$HOME/popm-address.json"

    echo "备份 address.json 文件..."
    if [ -f "$ADDRESS_FILE" ]; then
        echo "备份内容："
        cat "$ADDRESS_FILE"
        echo "您可以复制以上信息。"
    else
        echo "未找到 address.json 文件，无法备份。"
    fi
    read -p "按回车返回主菜单..." enter
}

# 功能6：升级 Heminetwork
upgrade_version() {
    download_and_setup
    echo "版本升级完成！"
    read -p "按回车返回主菜单..." enter
}

# 功能7：卸载 Heminetwork
uninstall_heminetwork() {
    echo "正在卸载 Heminetwork..."
    rm -rf /root/heminetwork*
    echo "Heminetwork 已卸载。"
    read -p "按回车返回主菜单..." enter
}

# 主菜单
main_menu() {
    while true; do
        clear
        echo "===== Heminetwork 管理菜单 ====="
        echo "1. 下载并设置 Heminetwork"
        echo "2. 设置环境变量"
        echo "3. 启动 popmd"
        echo "4. 查看日志（使用 Ctrl + A + D 退出）"
        echo "5. 备份地址信息"
        echo "6. 升级 Heminetwork"
        echo "7. 卸载 Heminetwork"
        echo "8. 退出"
        echo "==============================="
        echo "脚本作者: K2 节点教程分享"
        echo "关注推特: https://x.com/BtcK241918"
        echo "==============================="
        echo "请选择操作:"

        read -p "请输入选项 (1-8): " choice

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
                uninstall_heminetwork
                ;;
            8)
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
