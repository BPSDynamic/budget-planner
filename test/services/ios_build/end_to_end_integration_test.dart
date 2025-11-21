import 'package:flutter_test/flutter_test.dart';
import 'package:budget_planner/services/ios_build/report_generator.dart';
import 'package:budget_planner/services/ios_build/build_cache_manager.dart';
import 'package:budget_planner/services/ios_build/models/test_result.dart';

void main() {
  group('End-to-End iOS Build & Test Workflows', () {
    late ReportGenerator reportGenerator;
    late BuildCacheManager cacheManager;

    setUp(() {
      reportGenerator = ReportGenerator();
      cacheManager = BuildCacheManager(cacheDirectory: '.build_cache_test');
    });

    group('Test Report Generation Workflow', () {
      test('generates comprehensive test report with statistics', () {
        // Arrange
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_login',
            testType: 'unit',
            status: 'passed',
            duration: 150,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
          TestResult(
            testName: 'test_logout',
            testType: 'unit',
            status: 'passed',
            duration: 120,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
          TestResult(
            testName: 'test_invalid_credentials',
            testType: 'unit',
            status: 'failed',
            duration: 200,
            errorMessage: 'Expected exception not thrown',
            stackTrace: 'at test_invalid_credentials',
            timestamp: DateTime.now(),
          ),
        ];

        // Act
        final report = reportGenerator.generateTestReport(
          reportId: 'report-e2e-001',
          simulatorId: 'sim-e2e-001',
          testResults: testResults,
          duration: 470,
        );

        // Assert
        expect(report, isNotNull);
        expect(report.totalTests, equals(3));
        expect(report.passedTests, equals(2));
        expect(report.failedTests, equals(1));
        expect(report.skippedTests, equals(0));
        expect(report.duration, equals(470));
      });

      test('exports test report as JSON', () {
        // Arrange
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];
        final report = reportGenerator.generateTestReport(
          reportId: 'report-001',
          simulatorId: 'sim-001',
          testResults: testResults,
          duration: 100,
        );

        // Act
        final jsonReport = reportGenerator.exportReportAsJSON(report);

        // Assert
        expect(jsonReport, isNotNull);
        expect(jsonReport, contains('totalTests'));
        expect(jsonReport, contains('passedTests'));
        expect(jsonReport, contains('failedTests'));
      });

      test('exports test report as HTML', () {
        // Arrange
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];
        final report = reportGenerator.generateTestReport(
          reportId: 'report-001',
          simulatorId: 'sim-001',
          testResults: testResults,
          duration: 100,
        );

        // Act
        final htmlReport = reportGenerator.exportReportAsHTML(report);

        // Assert
        expect(htmlReport, isNotNull);
        expect(htmlReport, contains('<html>'));
        expect(htmlReport, contains('Test Report'));
        expect(htmlReport, contains('Total Tests'));
      });
    });

    group('Build Report Generation Workflow', () {
      test('generates build report with metrics', () {
        // Act
        final report = reportGenerator.generateBuildReport(
          buildId: 'build-e2e-001',
          status: 'success',
          duration: 45000,
          artifactPath: '/build/ios/app.app',
          dependencyCount: 25,
          cacheHitCount: 12,
        );

        // Assert
        expect(report, isNotNull);
        expect(report.status, equals('success'));
        expect(report.duration, equals(45000));
        expect(report.artifactPath, equals('/build/ios/app.app'));
        expect(report.dependencyCount, equals(25));
        expect(report.cacheHitCount, equals(12));
      });

      test('exports build report as HTML', () {
        // Arrange
        final report = reportGenerator.generateBuildReport(
          buildId: 'build-001',
          status: 'success',
          duration: 5000,
          artifactPath: '/build/ios/app.app',
          dependencyCount: 10,
          cacheHitCount: 5,
        );

        // Act
        final htmlReport = reportGenerator.exportBuildReportAsHTML(report);

        // Assert
        expect(htmlReport, isNotNull);
        expect(htmlReport, contains('<html>'));
        expect(htmlReport, contains('Build Report'));
        expect(htmlReport, contains('success'));
      });
    });

    group('Build Cache Workflow', () {
      test('reports cache statistics', () async {
        // Act
        final stats = await cacheManager.getCacheStats();

        // Assert
        expect(stats, isNotNull);
        expect(stats['cacheHits'], greaterThanOrEqualTo(0));
        expect(stats['cacheMisses'], greaterThanOrEqualTo(0));
        expect(stats['totalRequests'], greaterThanOrEqualTo(0));
      });

      test('clears all cache entries', () async {
        // Act
        await cacheManager.clearCache();
        final stats = await cacheManager.getCacheStats();

        // Assert
        expect(stats, isNotNull);
        expect(stats['fileCount'], equals(0));
      });
    });

    group('Multi-Version Compatibility Report', () {
      test('generates compatibility report for multiple iOS versions', () {
        // Arrange
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];
        final resultsByVersion = {
          '16.0': testResults,
          '17.0': testResults,
          '18.0': testResults,
        };

        // Act
        final report = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-e2e-001',
          resultsByVersion: resultsByVersion,
          totalDuration: 300,
        );

        // Assert
        expect(report, isNotNull);
        expect(report['summary']['totalVersions'], equals(3));
        expect(report['versionReports'], isNotNull);
        expect(report['versionReports'].length, equals(3));
      });

      test('exports compatibility report as HTML', () {
        // Arrange
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];
        final resultsByVersion = {
          '16.0': testResults,
          '17.0': testResults,
        };
        final report = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-001',
          resultsByVersion: resultsByVersion,
          totalDuration: 200,
        );

        // Act
        final htmlReport = reportGenerator.exportCompatibilityReportAsHTML(report);

        // Assert
        expect(htmlReport, isNotNull);
        expect(htmlReport, contains('<html>'));
        expect(htmlReport, contains('Compatibility Report'));
        expect(htmlReport, contains('16.0'));
        expect(htmlReport, contains('17.0'));
      });
    });

    group('Complete End-to-End Workflow Scenarios', () {
      test('validates complete build and test report generation workflow', () {
        // Arrange - Simulate build results
        final buildReport = reportGenerator.generateBuildReport(
          buildId: 'build-e2e-complete-001',
          status: 'success',
          duration: 60000,
          artifactPath: '/build/ios/app.app',
          dependencyCount: 30,
          cacheHitCount: 15,
        );

        // Arrange - Simulate test results
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_auth_flow',
            testType: 'integration',
            status: 'passed',
            duration: 500,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
          TestResult(
            testName: 'test_budget_creation',
            testType: 'integration',
            status: 'passed',
            duration: 450,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
          TestResult(
            testName: 'test_transaction_add',
            testType: 'integration',
            status: 'passed',
            duration: 400,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];

        final testReport = reportGenerator.generateTestReport(
          reportId: 'report-e2e-complete-001',
          simulatorId: 'sim-e2e-complete-001',
          testResults: testResults,
          duration: 1350,
        );

        // Act - Export reports
        final jsonBuildReport = reportGenerator.exportBuildReportAsJSON(buildReport);
        final jsonTestReport = reportGenerator.exportReportAsJSON(testReport);
        final htmlBuildReport = reportGenerator.exportBuildReportAsHTML(buildReport);
        final htmlTestReport = reportGenerator.exportReportAsHTML(testReport);

        // Assert
        expect(buildReport.status, equals('success'));
        expect(testReport.totalTests, equals(3));
        expect(testReport.passedTests, equals(3));
        expect(testReport.failedTests, equals(0));
        expect(jsonBuildReport, isNotNull);
        expect(jsonTestReport, isNotNull);
        expect(htmlBuildReport, isNotNull);
        expect(htmlTestReport, isNotNull);
      });

      test('validates multi-version testing workflow with aggregation', () {
        // Arrange - Create test results for multiple versions
        final testResults = <TestResult>[
          TestResult(
            testName: 'test_ui_rendering',
            testType: 'widget',
            status: 'passed',
            duration: 200,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
          TestResult(
            testName: 'test_data_persistence',
            testType: 'unit',
            status: 'passed',
            duration: 150,
            errorMessage: null,
            stackTrace: null,
            timestamp: DateTime.now(),
          ),
        ];

        final resultsByVersion = {
          '16.0': testResults,
          '17.0': testResults,
          '18.0': testResults,
        };

        // Act - Generate compatibility report
        final compatReport = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-e2e-multi-001',
          resultsByVersion: resultsByVersion,
          totalDuration: 1050,
        );

        // Act - Export as HTML
        final htmlReport = reportGenerator.exportCompatibilityReportAsHTML(compatReport);

        // Assert
        expect(compatReport['summary']['totalVersions'], equals(3));
        expect(compatReport['summary']['allVersionsPassed'], isTrue);
        expect(htmlReport, contains('Multi-Version Compatibility Report'));
        expect(htmlReport, contains('16.0'));
        expect(htmlReport, contains('17.0'));
        expect(htmlReport, contains('18.0'));
      });

      test('validates build cache statistics workflow', () async {
        // Act - Get cache statistics
        final stats = await cacheManager.getCacheStats();

        // Assert
        expect(stats, isNotNull);
        expect(stats['cacheHits'], greaterThanOrEqualTo(0));
        expect(stats['cacheMisses'], greaterThanOrEqualTo(0));
        expect(stats['totalRequests'], greaterThanOrEqualTo(0));
      });
    });
  });
}
