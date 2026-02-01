#!/bin/bash

# Alfred Script Filter - 列出被系统拦截的应用
# 扫描多个常见位置，找出所有被 Gatekeeper 阻止的应用

blocked_items=()
item_paths=()

# 检查应用是否被拦截
# quarantine 属性格式: flag;timestamp;source;uuid
# flag 说明:
#   0001, 0002 = 下载但未运行
#   0081, 0381 = 被阻止，需要用户在系统设置中允许
#   00c1, 03c1 = 已被用户允许（不应显示）
check_blocked() {
    local app_path="$1"
    
    local quarantine=$(xattr -p com.apple.quarantine "$app_path" 2>/dev/null)
    if [ -z "$quarantine" ]; then
        return 1  # 没有 quarantine 属性
    fi
    
    local flag=$(echo "$quarantine" | cut -d';' -f1)
    
    case "$flag" in
        "0081"|"0381")
            # 被阻止，需要用户允许
            return 0
            ;;
        "0001"|"0002")
            # 下载但未运行，可能首次打开会被阻止
            # 检查是否有有效签名
            if ! codesign -v "$app_path" 2>/dev/null; then
                return 0  # 签名无效，可能会被阻止
            fi
            ;;
    esac
    
    return 1  # 已允许或不需要处理
}

# 用于去重的关联数组
declare -A seen_paths

# 扫描目录中的应用
scan_directory() {
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
                app_name=$(basename "$app_path" .app)
                blocked_items+=("$app_name")
                item_paths+=("$app_path")
            fi
        fi
    done < <(find "$dir" -maxdepth "$max_depth" -name "*.app" -type d 2>/dev/null)
}

# 扫描常见应用目录
scan_directory "/Applications" 2
scan_directory "$HOME/Applications" 2

# 扫描下载目录（用户可能直接运行下载的应用）
scan_directory "$HOME/Downloads" 3

# 扫描桌面
scan_directory "$HOME/Desktop" 2

# 扫描常见的开发/工具目录
scan_directory "/opt/homebrew/Caskroom" 3
scan_directory "/usr/local/Caskroom" 3

# 从系统最近的 Gatekeeper 拒绝记录中查找（如果可访问）
if [ -r "/var/db/SystemPolicy/.LastGKReject" ]; then
    last_reject=$(cat "/var/db/SystemPolicy/.LastGKReject" 2>/dev/null)
    if [ -n "$last_reject" ] && [ -d "$last_reject" ]; then
        if [ -z "${seen_paths[$last_reject]}" ]; then
            if check_blocked "$last_reject"; then
                seen_paths[$last_reject]=1
                app_name=$(basename "$last_reject" .app)
                blocked_items+=("$app_name")
                item_paths+=("$last_reject")
            fi
        fi
    fi
fi

# 生成 Alfred Script Filter JSON 输出
cat << EOF
{
  "items": [
EOF

if [ ${#blocked_items[@]} -eq 0 ]; then
    cat << EOF
    {
      "title": "✅ 没有发现被系统拦截的应用",
      "subtitle": "所有应用都可以正常运行",
      "icon": {
        "path": "icon_item.png"
      },
      "valid": false
    }
EOF
else
    cat << EOF
    {
      "title": "🎯 允许所有被拦截的应用",
      "subtitle": "一键解除 ${#blocked_items[@]} 个应用的系统拦截",
      "arg": "ALL",
      "icon": {
        "path": "icon_item.png"
      }
    }
EOF

    for i in "${!blocked_items[@]}"; do
        item_name="${blocked_items[i]}"
        item_path="${item_paths[i]}"
        
        cat << EOF
,
    {
      "title": "🚫 $item_name",
      "subtitle": "点击解除拦截并启动 → $item_path",
      "arg": "$item_path",
      "icon": {
        "type": "fileicon",
        "path": "$item_path"
      }
    }
EOF
    done
fi

cat << EOF
  ]
}
EOF
