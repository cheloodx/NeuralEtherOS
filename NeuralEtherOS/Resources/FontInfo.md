# Custom Fonts

Add the following font files to this directory and register them in Info.plist:

## Required Fonts

### Space Grotesk (Headlines & Display)
- SpaceGrotesk-Bold.ttf
- SpaceGrotesk-SemiBold.ttf
- SpaceGrotesk-Medium.ttf
Download: https://fonts.google.com/specimen/Space+Grotesk

### Inter (Body & UI)
- Inter-Regular.ttf
- Inter-Medium.ttf
Download: https://fonts.google.com/specimen/Inter

### JetBrains Mono (Logs & Code)
- JetBrainsMono-Regular.ttf
Download: https://www.jetbrains.com/lp/mono/

## Info.plist Configuration

Add to your Info.plist under "Fonts provided by application" (UIAppFonts):

```xml
<key>UIAppFonts</key>
<array>
    <string>SpaceGrotesk-Bold.ttf</string>
    <string>SpaceGrotesk-SemiBold.ttf</string>
    <string>SpaceGrotesk-Medium.ttf</string>
    <string>Inter-Regular.ttf</string>
    <string>Inter-Medium.ttf</string>
    <string>JetBrainsMono-Regular.ttf</string>
</array>
```

Note: If fonts are not installed, the app falls back to system fonts automatically.
