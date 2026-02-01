#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Build script for Allow Blocked Apps Alfred Workflow
"""

import os
import zipfile
import shutil

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(BASE_DIR, 'src')
OUTPUT_FILE = os.path.join(BASE_DIR, 'Allow-Blocked-Apps.alfredworkflow')

def create_workflow():
    """Create Alfred workflow file from source scripts"""
    
    print("🎁 Building Alfred Workflow...")
    print("")
    
    # Remove old workflow file
    if os.path.exists(OUTPUT_FILE):
        os.remove(OUTPUT_FILE)
        print("🗑️  Removed old workflow file")
    
    # Read script paths
    list_script_path = os.path.join(SRC_DIR, 'alfred_list.sh')
    allow_script_path = os.path.join(SRC_DIR, 'alfred_allow.sh')
    
    # Verify scripts exist
    if not os.path.exists(list_script_path):
        print(f"❌ Error: {list_script_path} not found")
        return False
    
    if not os.path.exists(allow_script_path):
        print(f"❌ Error: {allow_script_path} not found")
        return False
    
    # Create info.plist content
    info_plist = f'''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>bundleid</key>
	<string>com.allow.apps</string>
	<key>category</key>
	<string>Tools</string>
	<key>connections</key>
	<dict>
		<key>SF001</key>
		<array>
			<dict>
				<key>destinationuid</key>
				<string>RS001</string>
				<key>modifiers</key>
				<integer>0</integer>
				<key>modifiersubtext</key>
				<string></string>
			</dict>
		</array>
	</dict>
	<key>createdby</key>
	<string>Allow Blocked Apps Contributors</string>
	<key>description</key>
	<string>快速允许被Mac阻止的应用</string>
	<key>disabled</key>
	<false/>
	<key>name</key>
	<string>Allow Blocked Apps</string>
	<key>objects</key>
	<array>
		<dict>
			<key>config</key>
			<dict>
				<key>alfredfiltersresults</key>
				<true/>
				<key>argumenttrimmode</key>
				<integer>0</integer>
				<key>argumenttype</key>
				<integer>1</integer>
				<key>escaping</key>
				<integer>102</integer>
				<key>keyword</key>
				<string>allow</string>
				<key>queuedelaycustom</key>
				<integer>3</integer>
				<key>queuedelayimmediatelyinitially</key>
				<true/>
				<key>queuedelaymode</key>
				<integer>0</integer>
				<key>queuemode</key>
				<integer>1</integer>
				<key>runningsubtext</key>
				<string>正在扫描被阻止的应用...</string>
				<key>script</key>
				<string>{list_script_path}</string>
				<key>scriptargtype</key>
				<integer>1</integer>
				<key>scriptfile</key>
				<string></string>
				<key>subtext</key>
				<string>显示所有被阻止的应用</string>
				<key>title</key>
				<string>Allow Blocked Apps</string>
				<key>type</key>
				<integer>5</integer>
				<key>withspace</key>
				<false/>
			</dict>
			<key>type</key>
			<string>alfred.workflow.input.scriptfilter</string>
			<key>uid</key>
			<string>SF001</string>
			<key>version</key>
			<integer>3</integer>
		</dict>
		<dict>
			<key>config</key>
			<dict>
				<key>concurrently</key>
				<false/>
				<key>escaping</key>
				<integer>102</integer>
				<key>script</key>
				<string>{allow_script_path} "$1"</string>
				<key>scriptargtype</key>
				<integer>1</integer>
				<key>scriptfile</key>
				<string></string>
				<key>type</key>
				<integer>5</integer>
			</dict>
			<key>type</key>
			<string>alfred.workflow.action.script</string>
			<key>uid</key>
			<string>RS001</string>
			<key>version</key>
			<integer>2</integer>
		</dict>
	</array>
	<key>readme</key>
	<string>快速解锁被阻止的应用 - 告别繁琐的系统设置操作

使用方法:
1. 按下 Alfred 快捷键
2. 输入 "allow"
3. 选择应用并按 Enter

项目地址: https://github.com/dontloseyourway/alfred-allow-blocked-apps
</string>
	<key>uidata</key>
	<dict>
		<key>RS001</key>
		<dict>
			<key>xpos</key>
			<integer>300</integer>
			<key>ypos</key>
			<integer>50</integer>
		</dict>
		<key>SF001</key>
		<dict>
			<key>xpos</key>
			<integer>50</integer>
			<key>ypos</key>
			<integer>50</integer>
		</dict>
	</dict>
	<key>version</key>
	<string>1.0.0</string>
	<key>webaddress</key>
	<string>https://github.com/dontloseyourway/alfred-allow-blocked-apps</string>
</dict>
</plist>'''
    
    # Create workflow ZIP file
    print("📦 Creating workflow package...")
    try:
        with zipfile.ZipFile(OUTPUT_FILE, 'w', zipfile.ZIP_DEFLATED) as zipf:
            # Add info.plist
            zipf.writestr('info.plist', info_plist)
            print("   ✅ Added info.plist")
    
        print("")
        print("✅ Workflow created successfully!")
        print("")
        print(f"📍 Output: {OUTPUT_FILE}")
        print("")
        print("🚀 Installation:")
        print("   Double-click the .alfredworkflow file to install")
        print("")
        return True
        
    except Exception as e:
        print(f"❌ Error creating workflow: {e}")
        return False

if __name__ == "__main__":
    success = create_workflow()
    exit(0 if success else 1)
