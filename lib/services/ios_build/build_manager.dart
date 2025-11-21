import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'interfaces/build_manager_interface.dart';
import 'models/build_config.dart';
import 'models/build_report.dart';

/// Implementation of iOS app build management
class BuildManager implements BuildManagerInterface {
  final String projectRoot;
  BuildReport? _lastBuildReport;
  DateTime? _lastBuildTime;

  BuildManager({required this.projectRoot});

  /// Resolve all Flutter and native iOS dependencies
  @override
  Future<void> resolveDependencies() async {
    try {
      final result = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to resolve dependencies: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error resolving dependencies: $e');
    }
  }

  /// Install iOS packages using CocoaPods
  @override
  Future<void> installCocoaPods() async {
    try {
      final iosPath = '$projectRoot/ios';
      final podfileExists = await File('$iosPath/Podfile').exists();

      if (!podfileExists) {
        throw Exception('Podfile not found at $iosPath/Podfile');
      }

      final result = await Process.run(
        'pod',
        ['install', '--repo-update'],
        workingDirectory: iosPath,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to install CocoaPods: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error installing CocoaPods: $e');
    }
  }

  /// Build the Flutter app for iOS
  @override
  Future<void> buildApp(String buildMode) async {
    try {
      _lastBuildTime = DateTime.now();

      final result = await Process.run(
        'flutter',
        ['build', 'ios', '--$buildMode', '--no-codesign'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to build iOS app: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error building iOS app: $e');
    }
  }

  /// Get the path to the built iOS app artifact
  @override
  Future<String> getBuildArtifact() async {
    try {
      final buildDir = '$projectRoot/build/ios/iphoneos';
      final dir = Directory(buildDir);

      if (!await dir.exists()) {
        throw Exception('Build directory not found at $buildDir');
      }

      final appFiles = dir.listSync().whereType<Directory>().where((d) => d.path.endsWith('.app'));

      if (appFiles.isEmpty) {
        throw Exception('No .app file found in build directory');
      }

      final appPath = appFiles.first.path;
      return appPath;
    } catch (e) {
      throw Exception('Error getting build artifact: $e');
    }
  }

  /// Get the current build status and metrics
  @override
  Future<BuildReport> reportBuildStatus() async {
    try {
      final artifactPath = await getBuildArtifact();
      final duration = _lastBuildTime != null ? DateTime.now().difference(_lastBuildTime!).inMilliseconds : 0;

      final report = BuildReport(
        buildId: _generateBuildId(),
        status: 'success',
        duration: duration,
        artifactPath: artifactPath,
        dependencyCount: await _countDependencies(),
        cacheHitCount: 0,
        timestamp: DateTime.now(),
      );

      _lastBuildReport = report;
      return report;
    } catch (e) {
      throw Exception('Error reporting build status: $e');
    }
  }

  /// Clean build artifacts and cache
  @override
  Future<void> cleanBuild() async {
    try {
      final buildDir = Directory('$projectRoot/build');
      if (await buildDir.exists()) {
        await buildDir.delete(recursive: true);
      }

      final result = await Process.run(
        'flutter',
        ['clean'],
        workingDirectory: projectRoot,
      );

      if (result.exitCode != 0) {
        throw Exception('Failed to clean build: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error cleaning build: $e');
    }
  }

  /// Generate a unique build ID
  String _generateBuildId() {
    return md5.convert('${DateTime.now().toIso8601String()}'.codeUnits).toString().substring(0, 12);
  }

  /// Count the number of dependencies
  Future<int> _countDependencies() async {
    try {
      final pubspecFile = File('$projectRoot/pubspec.yaml');
      if (!await pubspecFile.exists()) {
        return 0;
      }

      final content = await pubspecFile.readAsString();
      final lines = content.split('\n');

      int dependencyCount = 0;
      bool inDependencies = false;

      for (final line in lines) {
        if (line.startsWith('dependencies:')) {
          inDependencies = true;
          continue;
        }

        if (inDependencies && line.startsWith('dev_dependencies:')) {
          break;
        }

        if (inDependencies && line.startsWith('  ') && !line.startsWith('    ')) {
          dependencyCount++;
        }
      }

      return dependencyCount;
    } catch (e) {
      return 0;
    }
  }
}
