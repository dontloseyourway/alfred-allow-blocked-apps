#!/bin/bash

# Alfred终极简化版 - 允许被阻止的应用
# 直接在Alfred中显示结果

# 扫描被阻止的应用
blocked_apps=()
app_paths=()

for app in /Applications/*.app; do
    if [ -d "$app" ]; then
        if xattr "$app" 2>/dev/null | grep -q "com.apple.quarantine"; then
            app_name=$(basename "$app" .app)
            blocked_apps+=("$app_name")
            app_paths+=("$app")
        fi
    fi
done

# 生成Alfred Script Filter JSON输出
cat << EOF
{
  "items": [
EOF

if [ ${#blocked_apps[@]} -eq 0 ]; then
    cat << EOF
    {
      "title": "没有发现被阻止的应用",
      "subtitle": "✅ 所有应用都可以正常运行",
      "icon": {
        "path": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarInfo.icns"
      },
      "valid": false
    }
EOF
else
    # 添加"允许所有"选项
    cat << EOF
    {
      "title": "🎯 允许所有被阻止的应用",
      "subtitle": "一键解除所有 ${#blocked_apps[@]} 个被阻止的应用",
      "arg": "ALL",
      "icon": {
        "path": "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/ToolbarCustomizeIcon.icns"
      }
    },
EOF

    # 添加每个被阻止的应用
    for i in "${!blocked_apps[@]}"; do
        app_name="${blocked_apps[i]}"
        app_path="${app_paths[i]}"
        
        # 检查是否是最后一个元素（决定是否添加逗号）
        if [ $i -eq $((${#blocked_apps[@]} - 1)) ]; then
            comma=""
        else
            comma=","
        fi
        
        cat << EOF
    {
      "title": "🚫 $app_name",
      "subtitle": "点击允许此应用运行",
      "arg": "$app_path",
      "icon": {
        "type": "fileicon",
        "path": "$app_path"
      }
    }$comma
EOF
    done
fi

cat << EOF
  ]
}
EOF