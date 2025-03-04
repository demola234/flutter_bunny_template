echo "|Create DeepLink Android|"
adb shell am start -a android.intent.action.VIEW \
    -c android.intent.category.BROWSABLE \
    -d "http://{{host_url}}" \
    {{bundle_identifier}}


echo "|Create DeepLink IOS|"
xcrun simctl openurl booted "appscheme://{{host_url}}"