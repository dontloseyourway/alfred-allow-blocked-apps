#!/bin/bash

# Alfred执行脚本 - 解除系统拦截
# 使用 macOS 钥匙串安全存储密码，只需输入一次

item_path="$1"

KEYCHAIN_SERVICE="com.alfred.allow-blocked-apps"
KEYCHAIN_ACCOUNT="admin-password"

# 从钥匙串获取密码
get_password_from_keychain() {
    security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null
}

# 保存密码到钥匙串
save_password_to_keychain() {
    local password="$1"
    # 先删除旧的（如果存在）
    security delete-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" 2>/dev/null
    # 添加新密码
    security add-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w "$password" 2>/dev/null
}

# 验证密码是否正确
verify_password() {
    local password="$1"
    echo "$password" | sudo -S true 2>/dev/null
    return $?
}

# 确保有管理员密码
ensure_password() {
    # 首先尝试从钥匙串获取
    local password
    password=$(get_password_from_keychain)
    
    if [ -n "$password" ]; then
        # 验证密码是否仍然有效
        if verify_password "$password"; then
            echo "$password"
            return 0
        fi
        # 密码无效，需要重新输入
    fi
    
    # 通过 AppleScript 获取密码
    password=$(osascript -e 'display dialog "请输入管理员密码以解除应用拦截" & return & return & "密码将安全保存在钥匙串中，以后无需重复输入" default answer "" with hidden answer with title "🔐 需要管理员权限" with icon caution buttons {"取消", "确定"} default button "确定"' -e 'text returned of result' 2>/dev/null)
    
    if [ -z "$password" ]; then
        return 1  # 用户取消
    fi
    
    # 验证密码
    if ! verify_password "$password"; then
        osascript -e "display notification \"密码错误，请重试\" with title \"❌ 验证失败\" sound name \"Basso\""
        return 1
    fi
    
    # 保存到钥匙串
    save_password_to_keychain "$password"
    echo "$password"
    return 0
}

# 使用密码执行 sudo 命令
run_with_sudo() {
    local password="$1"
    shift
    echo "$password" | sudo -S "$@" 2>/dev/null
}

# 检查应用是否被拦截
check_blocked() {
    local app_path="$1"
    local quarantine=$(xattr -p com.apple.quarantine "$app_path" 2>/dev/null)
    if [ -z "$quarantine" ]; then
        return 1
    fi
    local flag=$(echo "$quarantine" | cut -d';' -f1)
    if [[ "$flag" == "0081" || "$flag" == "0381" ]]; then
        return 0
    fi
    if [[ "$flag" == "0001" || "$flag" == "0002" ]]; then
        if ! codesign -v "$app_path" 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# 扫描目录中的被拦截应用
scan_blocked_apps() {
    local dir="$1"
    local max_depth="${2:-2}"
    
    if [ ! -d "$dir" ]; then
        return
    fi
    
    while IFS= read -r app_path; do
        if [ -d "$app_path" ]; then
            # 去重
            if [ -n "${seen_paths[$app_path]}" ]; then
                continue
            fi
            seen_paths[$app_path]=1
            
            if check_blocked "$app_path"; then
                apps_to_allow+=("$app_path")
                app_names+=("$(basename "$app_path" .app)")
            fi
        fi
    done < <(find "$dir" -maxdepth "$max_depth" -name "*.app" -type d 2>/dev/null)
}

# 允许所有模式
if [ "$item_path" == "ALL" ]; then
    # 收集所有需要解除拦截的应用
    declare -A seen_paths
    apps_to_allow=()
    app_names=()
    
    # 扫描常见应用目录
    scan_blocked_apps "/Applications" 2
    scan_blocked_apps "$HOME/Applications" 2
    
    # 扫描下载目录
    scan_blocked_apps "$HOME/Downloads" 3
    
    # 扫描桌面
    scan_blocked_apps "$HOME/Desktop" 2
    
    # 扫描 Homebrew Caskroom
    scan_blocked_apps "/opt/homebrew/Caskroom" 3
    scan_blocked_apps "/usr/local/Caskroom" 3
    
    if [ ${#apps_to_allow[@]} -eq 0 ]; then
        osascript -e "display notification \"没有需要解除的拦截\" with title \"✅ 完成\" sound name \"Glass\""
        exit 0
    fi
    
    # 获取密码
    password=$(ensure_password)
    if [ -z "$password" ]; then
        osascript -e "display notification \"用户取消了操作\" with title \"ℹ️ 已取消\" sound name \"Purr\""
        exit 0
    fi
    
    # 显示处理中
    count=${#apps_to_allow[@]}
    osascript -e "display notification \"正在处理 $count 个应用...\" with title \"⏳ 解除拦截中\" sound name \"Purr\""
    
    # 批量执行
    for app_path in "${apps_to_allow[@]}"; do
        run_with_sudo "$password" xattr -rd com.apple.quarantine "$app_path"
        run_with_sudo "$password" xattr -d com.apple.provenance "$app_path"
    done
    
    names_str=$(IFS=', '; echo "${app_names[*]}")
    osascript -e "display notification \"$names_str\" with title \"✅ 已解除 $count 个应用的拦截\" sound name \"Glass\""
    exit 0
fi

# 单个文件/应用模式
item_name=$(basename "$item_path")
if [[ "$item_name" == *.app ]]; then
    item_name="${item_name%.app}"
fi

# 检查文件是否存在
if [ ! -e "$item_path" ]; then
    osascript -e "display notification \"找不到应用: $item_name\" with title \"❌ 错误\" sound name \"Basso\""
    exit 1
fi

# 获取密码
password=$(ensure_password)
if [ -z "$password" ]; then
    osascript -e "display notification \"用户取消了操作\" with title \"ℹ️ 已取消\" sound name \"Purr\""
    exit 0
fi

# 显示处理中
osascript -e "display notification \"正在解除拦截...\" with title \"⏳ 处理中\" sound name \"Purr\""

# 执行解除拦截
run_with_sudo "$password" xattr -rd com.apple.quarantine "$item_path"
run_with_sudo "$password" xattr -d com.apple.provenance "$item_path"

# 完成通知并启动应用
osascript -e "display notification \"正在启动 $item_name...\" with title \"✅ 解除成功\" sound name \"Glass\""
sleep 0.3
open "$item_path"
