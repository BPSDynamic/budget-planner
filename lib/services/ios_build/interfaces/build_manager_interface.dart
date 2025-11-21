import '../models/build_config.dart';
import '../models/build_report.dart';

/// Abstract interface for iOS app build management
abstract class BuildManagerInterface {
  /// Resolve all Flutter and native iOS dependencies
  Future<void> resolveDependencies();

  /// Install iOS packages using CocoaPods
  Future<void> installCocoaPods();

  /// Build the Flutter app for iOS
  Future<void> buildApp(String buildMode);

  /// Get the path to the built iOS app artifact
  Future<String> getBuildArtifact();

  /// Get the current build status and metrics
  Future<BuildReport> reportBuildStatus();

  /// Clean build artifacts and cache
  Future<void> cleanBuild();
}
