#!/bin/bash

# Alfred执行脚本 - 允许应用运行

app_path="$1"

if [ "$app_path" == "ALL" ]; then
    # 允许所有被阻止的应用
    count=0
    for app in /Applications/*.app; do
        if [ -d "$app" ]; then
            if xattr "$app" 2>/dev/null | grep -q "com.apple.quarantine"; then
                sudo xattr -rd com.apple.quarantine "$app" 2>/dev/null
                if [ $? -eq 0 ]; then
                    count=$((count + 1))
                fi
            fi
        fi
    done
    
    if [ $count -gt 0 ]; then
        osascript -e "display notification \"已成功允许 $count 个应用\" with title \"✅ 完成\" sound name \"Glass\""
    else
        osascript -e "display notification \"没有需要允许的应用\" with title \"ℹ️ 提示\" sound name \"Purr\""
    fi
else
    # 允许单个应用
    app_name=$(basename "$app_path" .app)
    
    if [ -d "$app_path" ]; then
        sudo xattr -rd com.apple.quarantine "$app_path" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            osascript -e "display notification \"$app_name 现在可以正常运行了\" with title \"✅ 已允许\" sound name \"Glass\""
        else
            osascript -e "display notification \"允许失败，请检查权限\" with title \"❌ 错误\" sound name \"Basso\""
        fi
    else
        osascript -e "display notification \"找不到应用: $app_name\" with title \"❌ 错误\" sound name \"Basso\""
    fi
fi