/// Abstract interface for iOS app installation on emulator
abstract class AppInstallerInterface {
  /// Install an iOS app on the specified simulator
  Future<void> installApp(String simulatorId, String appPath);

  /// Verify that an app is installed on the simulator
  Future<bool> verifyInstallation(String simulatorId);

  /// Launch an app on the simulator
  Future<void> launchApp(String simulatorId, String bundleId);

  /// Uninstall an app from the simulator
  Future<void> uninstallApp(String simulatorId, String bundleId);
}
