import 'dart:async';
import 'dart:io';
import 'interfaces/app_installer_interface.dart';

/// Implementation of iOS app installation on emulator
class AppInstaller implements AppInstallerInterface {
  /// Install an iOS app on the specified simulator
  @override
  Future<void> installApp(String simulatorId, String appPath) async {
    try {
      // Verify the app path exists
      final appDir = Directory(appPath);
      if (!await appDir.exists()) {
        throw Exception('App path does not exist: $appPath');
      }

      // Install the app using xcrun simctl
      final result = await Process.run('xcrun', [
        'simctl',
        'install',
        simulatorId,
        appPath,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to install app: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error installing app: $e');
    }
  }

  /// Verify that an app is installed on the simulator
  @override
  Future<bool> verifyInstallation(String simulatorId) async {
    try {
      // Get the list of installed apps on the simulator
      final result = await Process.run('xcrun', [
        'simctl',
        'get_app_container',
        simulatorId,
        'com.example.budgetplanner',
      ]);

      // If the command succeeds, the app is installed
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Launch an app on the simulator
  @override
  Future<void> launchApp(String simulatorId, String bundleId) async {
    try {
      final result = await Process.run('xcrun', [
        'simctl',
        'launch',
        simulatorId,
        bundleId,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to launch app: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error launching app: $e');
    }
  }

  /// Uninstall an app from the simulator
  @override
  Future<void> uninstallApp(String simulatorId, String bundleId) async {
    try {
      final result = await Process.run('xcrun', [
        'simctl',
        'uninstall',
        simulatorId,
        bundleId,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to uninstall app: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error uninstalling app: $e');
    }
  }
}
