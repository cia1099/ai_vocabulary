#!/bin/zsh
fd bump_version.dart && ff build ios --release --no-tree-shake-icons
# 先 Archive
# xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/ios/archive/Runner.xcarchive -destination "generic/platform=iOS" archive DEVELOPMENT_TEAM=A74NS5RT64
# 再 Export 成 ipa (Fail in this step)
# xcodebuild -exportArchive -archivePath build/ios/archive/Runner.xcarchive -exportOptionsPlist ios/ExportOptions.plist -exportPath build/ios/ipa