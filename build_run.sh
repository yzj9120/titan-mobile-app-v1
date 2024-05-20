#!/bin/bash

# 从 pubspec.yaml 文件中提取应用名称和版本号
app_name=$(sed -n 's/^ *name: *\(.*\)/\1/p' pubspec.yaml | head -n 1)
version=$(sed -n 's/^ *version: *\(.*\)/\1/p' pubspec.yaml | head -n 1)

# 生成带有年月日时分秒的时间戳
current_date=$(date +"%Y%m%d%H%M%S")

# 拼接应用名称
app_name="${app_name}_${current_date}_v${version}"

# 构建 APK
flutter build apk --release

# 将 APK 复制到指定名称
cp build/app/outputs/flutter-apk/app-release.apk "${app_name}.apk"

echo "已生成应用包：${app_name}.apk"
