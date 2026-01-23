# iOS Widget Extension Setup

The widget Swift code has been created in this directory. Follow these steps to add the widget extension to your Xcode project:

## Step 1: Add Widget Extension Target

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project in the navigator
3. Click `File > New > Target`
4. Search for "Widget Extension"
5. Click `Next`
6. Set Product Name to: `VantagWidget`
7. Set Bundle Identifier to: `com.vantag.app.VantagWidget`
8. Uncheck "Include Configuration Intent" (we use static configuration)
9. Click `Finish`
10. If prompted to activate the scheme, click `Activate`

## Step 2: Replace Generated Files

1. Delete the auto-generated Swift file(s) in the VantagWidget group
2. Add `VantagWidget.swift` from this directory to the VantagWidget target
3. Replace the auto-generated `Info.plist` with the one from this directory

## Step 3: Configure App Groups

### For the Main App (Runner):
1. Select Runner target
2. Go to `Signing & Capabilities`
3. Click `+ Capability`
4. Add `App Groups`
5. Add group: `group.com.vantag.app`

### For the Widget Extension:
1. Select VantagWidget target
2. Go to `Signing & Capabilities`
3. Click `+ Capability`
4. Add `App Groups`
5. Add the same group: `group.com.vantag.app`

## Step 4: Update Deployment Target

1. Select VantagWidget target
2. Go to `General`
3. Set Minimum Deployments iOS to: `14.0` (same as main app or higher)

## Step 5: Build Settings

1. Select VantagWidget target
2. Go to `Build Settings`
3. Search for "Swift Language Version"
4. Set to: `5.0`

## Step 6: Verify home_widget Setup

In the main Runner `AppDelegate.swift`, ensure home_widget is properly registered.
The `GeneratedPluginRegistrant.register(with: self)` call handles this automatically.

## Testing

1. Build and run the app on a device or simulator
2. Long press on the home screen
3. Tap the `+` button to add widgets
4. Search for "Vantag"
5. Add the Small or Medium widget

## Troubleshooting

### Widget shows placeholder data
- Ensure the app has been opened at least once to populate widget data
- Verify App Groups are configured correctly on both targets
- Check that `group.com.vantag.app` matches exactly in:
  - Runner's App Groups
  - VantagWidget's App Groups
  - `VantagWidgetProvider.appGroupId` in Swift code
  - `WidgetService.appGroupId` in Dart code

### Widget doesn't appear in widget picker
- Clean build folder: `Product > Clean Build Folder`
- Delete app from device/simulator and reinstall
- Restart the simulator/device
