#!/bin/bash

# 定义菜单选项
function show_menu() {
    echo "请选择要执行的操作："
    echo "1. 部署 pipe pop节点"
    echo "2. 查看声誉"
    echo "3. 备份 info"
    echo "4. 生成pop邀请"
    echo "5. 升级版本（升级前建议备份info）"
    echo "6. 退出"
}

# 部署节点
function deploy_node() {
    echo "正在部署 pipe pop节点..."

    # 创建目录
    mkdir -p ~/pipe
    mkdir -p ~/pipe/download_cache
    cd ~/pipe

    # 下载 Pipe 二进制文件
    wget -O pop "https://dl.pipecdn.app/v0.2.4/pop"
    chmod +x pop

    # 设置系统服务
    read -p "请输入要分配的内存大小（例如 4 表示 4GB）：" ram_size
    read -p "请输入要分配的磁盘大小（例如 200 表示 200GB）：" disk_size
    read -p "请输入你的 Solana 公钥地址：" solana_address

    sudo tee /etc/systemd/system/pipe.service > /dev/null << EOF
[Unit]
Description=Pipe Node Service
After=network.target
Wants=network-online.target

[Service]
User=root
Group=root
WorkingDirectory=/root/pipe
ExecStart=/root/pipe/pop \
    --ram $ram_size \
    --max-disk $disk_size \
    --cache-dir /root/pipe/download_cache \
    --pubKey $solana_address \
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=dcdn-node

[Install]
WantedBy=multi-user.target
EOF

    # 启动服务
    sudo systemctl daemon-reload
    sudo systemctl enable pipe
    sudo systemctl start pipe

    echo "节点部署完成。"
}

# 查看声誉
function check_reputation() {
    echo "正在查看声誉..."
    cd ~/pipe
    ./pop --status
}

# 备份 info
function backup_info() {
    echo "正在备份 node_info.json 文件..."
    if [ -f ~/pipe/node_info.json ]; then
        cp ~/pipe/node_info.json ~/node_info.backup
        echo "备份完成，node_info.json 已备份到 ~/node_info.backup"
    else
        echo "node_info.json 文件不存在，无法备份。"
    fi
}

# 生成pop邀请
function generate_invite() {
    echo "正在生成pop邀请..."
    cd ~/pipe
    ./pop --gen-referral-route
}

# 升级版本
function upgrade_version() {
    echo "正在升级版本..."
    cd ~/pipe
    wget -O pop "https://dl.pipecdn.app/v0.2.4/pop"
    chmod +x pop
    echo "升级完成。"
}

# 主循环
while true; do
    show_menu
    read -p "请输入选项：" option
    case $option in
        1) deploy_node ;;
        2) check_reputation ;;
        3) backup_info ;;
        4) generate_invite ;;
        5) upgrade_version ;;
        6) echo "退出脚本。"; exit 0 ;;
        *) echo "无效选项，请重新选择。" ;;
    esac
    read -p "按任意键返回主菜单..." -n 1 -s
    echo
done

Initial commit:Added
