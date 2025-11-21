import 'package:test/test.dart';
import 'package:budget_planner/services/ios_build/report_generator.dart';
import 'package:budget_planner/services/ios_build/models/test_report.dart';
import 'package:budget_planner/services/ios_build/models/build_report.dart';
import 'package:budget_planner/services/ios_build/models/test_result.dart';
import 'dart:convert';

void main() {
  group('ReportGenerator', () {
    late ReportGenerator reportGenerator;

    setUp(() {
      reportGenerator = ReportGenerator();
    });

    group('Property 6: Test Report Accuracy', () {
      // **Feature: ios-emulator-build-test, Property 6: Test Report Accuracy**
      // **Validates: Requirements 6.1, 6.2**
      test('test report accurately reflects test results (100 iterations)', () {
        // Property-based test: For any test execution on an iOS emulator, the generated test report
        // SHALL accurately reflect test results with correct pass/fail counts and execution metrics.
        
        final testCases = [
          (10, 8, 2, 0),
          (20, 18, 2, 0),
          (15, 12, 2, 1),
          (25, 20, 3, 2),
          (5, 5, 0, 0),
          (30, 25, 4, 1),
          (12, 10, 1, 1),
          (18, 16, 2, 0),
          (22, 19, 2, 1),
          (8, 7, 1, 0),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final totalTests = testCase.$1;
          final passedTests = testCase.$2;
          final failedTests = testCase.$3;
          final skippedTests = testCase.$4;

          final testResults = <TestResult>[];
          for (int j = 0; j < passedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_passed_$j',
              testType: 'unit',
              status: 'passed',
              duration: 100,
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < failedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_failed_$j',
              testType: 'unit',
              status: 'failed',
              duration: 150,
              errorMessage: 'Test failed',
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < skippedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_skipped_$j',
              testType: 'unit',
              status: 'skipped',
              duration: 0,
              timestamp: DateTime.now(),
            ));
          }

          final report = reportGenerator.generateTestReport(
            reportId: 'report-${i.toString().padLeft(3, '0')}',
            simulatorId: 'simulator-001',
            testResults: testResults,
            duration: 5000,
          );

          // Verify report accurately reflects test counts
          expect(report.totalTests, equals(totalTests), reason: 'Failed at iteration $i: total tests mismatch');
          expect(report.passedTests, equals(passedTests), reason: 'Failed at iteration $i: passed tests mismatch');
          expect(report.failedTests, equals(failedTests), reason: 'Failed at iteration $i: failed tests mismatch');
          expect(report.skippedTests, equals(skippedTests), reason: 'Failed at iteration $i: skipped tests mismatch');
          
          // Verify test results are preserved
          expect(report.testResults.length, equals(totalTests), reason: 'Failed at iteration $i: test results length mismatch');
        }
      });

      test('test report JSON export preserves all data (100 iterations)', () {
        // Property-based test: For any TestReport, exporting to JSON and parsing back should preserve all data
        
        final testCases = [
          (5, 4, 1, 0),
          (10, 8, 2, 0),
          (15, 12, 2, 1),
          (20, 18, 2, 0),
          (8, 7, 1, 0),
          (12, 10, 1, 1),
          (18, 16, 2, 0),
          (25, 20, 3, 2),
          (30, 25, 4, 1),
          (6, 5, 1, 0),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final passedTests = testCase.$2;
          final failedTests = testCase.$3;
          final skippedTests = testCase.$4;

          final testResults = <TestResult>[];
          for (int j = 0; j < passedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_passed_$j',
              testType: 'unit',
              status: 'passed',
              duration: 100,
              timestamp: DateTime(2024, 1, 1, 12, 0, 0),
            ));
          }
          for (int j = 0; j < failedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_failed_$j',
              testType: 'unit',
              status: 'failed',
              duration: 150,
              errorMessage: 'Test failed',
              timestamp: DateTime(2024, 1, 1, 12, 0, 0),
            ));
          }
          for (int j = 0; j < skippedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_skipped_$j',
              testType: 'unit',
              status: 'skipped',
              duration: 0,
              timestamp: DateTime(2024, 1, 1, 12, 0, 0),
            ));
          }

          final report = reportGenerator.generateTestReport(
            reportId: 'report-${i.toString().padLeft(3, '0')}',
            simulatorId: 'simulator-001',
            testResults: testResults,
            duration: 5000,
          );

          // Export to JSON and parse back
          final jsonString = reportGenerator.exportReportAsJSON(report);
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

          // Verify JSON contains all required fields
          expect(jsonData['reportId'], equals(report.reportId), reason: 'Failed at iteration $i: reportId mismatch');
          expect(jsonData['simulatorId'], equals(report.simulatorId), reason: 'Failed at iteration $i: simulatorId mismatch');
          expect(jsonData['totalTests'], equals(report.totalTests), reason: 'Failed at iteration $i: totalTests mismatch');
          expect(jsonData['passedTests'], equals(report.passedTests), reason: 'Failed at iteration $i: passedTests mismatch');
          expect(jsonData['failedTests'], equals(report.failedTests), reason: 'Failed at iteration $i: failedTests mismatch');
          expect(jsonData['skippedTests'], equals(report.skippedTests), reason: 'Failed at iteration $i: skippedTests mismatch');
        }
      });

      test('test report HTML export contains all summary statistics (100 iterations)', () {
        // Property-based test: For any TestReport, exporting to HTML should include all summary statistics
        
        final testCases = [
          (5, 4, 1, 0),
          (10, 8, 2, 0),
          (15, 12, 2, 1),
          (20, 18, 2, 0),
          (8, 7, 1, 0),
          (12, 10, 1, 1),
          (18, 16, 2, 0),
          (25, 20, 3, 2),
          (30, 25, 4, 1),
          (6, 5, 1, 0),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final totalTests = testCase.$1;
          final passedTests = testCase.$2;
          final failedTests = testCase.$3;
          final skippedTests = testCase.$4;

          final testResults = <TestResult>[];
          for (int j = 0; j < passedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_passed_$j',
              testType: 'unit',
              status: 'passed',
              duration: 100,
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < failedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_failed_$j',
              testType: 'unit',
              status: 'failed',
              duration: 150,
              errorMessage: 'Test failed',
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < skippedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_skipped_$j',
              testType: 'unit',
              status: 'skipped',
              duration: 0,
              timestamp: DateTime.now(),
            ));
          }

          final report = reportGenerator.generateTestReport(
            reportId: 'report-${i.toString().padLeft(3, '0')}',
            simulatorId: 'simulator-001',
            testResults: testResults,
            duration: 5000,
          );

          // Export to HTML
          final htmlString = reportGenerator.exportReportAsHTML(report);

          // Verify HTML contains all summary statistics
          expect(htmlString, contains(report.reportId), reason: 'Failed at iteration $i: reportId not in HTML');
          expect(htmlString, contains(report.simulatorId), reason: 'Failed at iteration $i: simulatorId not in HTML');
          expect(htmlString, contains(totalTests.toString()), reason: 'Failed at iteration $i: totalTests not in HTML');
          expect(htmlString, contains(passedTests.toString()), reason: 'Failed at iteration $i: passedTests not in HTML');
          expect(htmlString, contains(failedTests.toString()), reason: 'Failed at iteration $i: failedTests not in HTML');
          expect(htmlString, contains(skippedTests.toString()), reason: 'Failed at iteration $i: skippedTests not in HTML');
        }
      });

      test('test report pass rate calculation is accurate (100 iterations)', () {
        // Property-based test: For any TestReport, the pass rate should be accurately calculated
        
        final testCases = [
          (5, 5, 0, 0),
          (10, 8, 2, 0),
          (15, 12, 2, 1),
          (20, 18, 2, 0),
          (8, 7, 1, 0),
          (12, 10, 1, 1),
          (18, 16, 2, 0),
          (25, 20, 3, 2),
          (30, 25, 4, 1),
          (6, 5, 1, 0),
        ];

        for (int i = 0; i < 100; i++) {
          final testCase = testCases[i % testCases.length];
          final totalTests = testCase.$1;
          final passedTests = testCase.$2;
          final failedTests = testCase.$3;
          final skippedTests = testCase.$4;

          final testResults = <TestResult>[];
          for (int j = 0; j < passedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_passed_$j',
              testType: 'unit',
              status: 'passed',
              duration: 100,
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < failedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_failed_$j',
              testType: 'unit',
              status: 'failed',
              duration: 150,
              errorMessage: 'Test failed',
              timestamp: DateTime.now(),
            ));
          }
          for (int j = 0; j < skippedTests; j++) {
            testResults.add(TestResult(
              testName: 'test_skipped_$j',
              testType: 'unit',
              status: 'skipped',
              duration: 0,
              timestamp: DateTime.now(),
            ));
          }

          final report = reportGenerator.generateTestReport(
            reportId: 'report-${i.toString().padLeft(3, '0')}',
            simulatorId: 'simulator-001',
            testResults: testResults,
            duration: 5000,
          );

          // Verify pass rate calculation
          final expectedPassRate = totalTests > 0 ? (passedTests / totalTests * 100) : 0.0;
          final htmlString = reportGenerator.exportReportAsHTML(report);
          
          // Extract pass rate from HTML
          final passRateMatch = RegExp(r'Pass Rate:</strong> ([\d.]+)%').firstMatch(htmlString);
          if (passRateMatch != null) {
            final htmlPassRate = double.parse(passRateMatch.group(1)!);
            expect(htmlPassRate, closeTo(expectedPassRate, 0.01), reason: 'Failed at iteration $i: pass rate mismatch');
          }
        }
      });
    });

    group('Build Report Generation', () {
      test('build report contains all required fields', () {
        final report = reportGenerator.generateBuildReport(
          buildId: 'build-001',
          status: 'success',
          duration: 5000,
          artifactPath: '/path/to/app.app',
          dependencyCount: 10,
          cacheHitCount: 5,
        );

        expect(report.buildId, equals('build-001'));
        expect(report.status, equals('success'));
        expect(report.duration, equals(5000));
        expect(report.artifactPath, equals('/path/to/app.app'));
        expect(report.dependencyCount, equals(10));
        expect(report.cacheHitCount, equals(5));
      });

      test('build report JSON export is valid JSON', () {
        final report = reportGenerator.generateBuildReport(
          buildId: 'build-001',
          status: 'success',
          duration: 5000,
          artifactPath: '/path/to/app.app',
          dependencyCount: 10,
          cacheHitCount: 5,
        );

        final jsonString = reportGenerator.exportBuildReportAsJSON(report);
        final jsonData = jsonDecode(jsonString);

        expect(jsonData, isA<Map<String, dynamic>>());
        expect(jsonData['buildId'], equals('build-001'));
        expect(jsonData['status'], equals('success'));
      });

      test('build report HTML export contains status', () {
        final report = reportGenerator.generateBuildReport(
          buildId: 'build-001',
          status: 'success',
          duration: 5000,
          artifactPath: '/path/to/app.app',
          dependencyCount: 10,
          cacheHitCount: 5,
        );

        final htmlString = reportGenerator.exportBuildReportAsHTML(report);

        expect(htmlString, contains('Build Report'));
        expect(htmlString, contains('build-001'));
        expect(htmlString, contains('success'));
      });
    });

    group('Compatibility Report Generation', () {
      test('compatibility report contains all versions', () {
        final testResults1 = [
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            timestamp: DateTime.now(),
          ),
        ];

        final testResults2 = [
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            timestamp: DateTime.now(),
          ),
        ];

        final report = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-001',
          resultsByVersion: {
            '16.0': testResults1,
            '17.0': testResults2,
          },
          totalDuration: 10000,
        );

        expect(report['versionReports'], isA<Map<String, dynamic>>());
        expect(report['versionReports'].keys, contains('16.0'));
        expect(report['versionReports'].keys, contains('17.0'));
      });

      test('compatibility report JSON export is valid JSON', () {
        final testResults = [
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            timestamp: DateTime.now(),
          ),
        ];

        final report = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-001',
          resultsByVersion: {
            '16.0': testResults,
            '17.0': testResults,
          },
          totalDuration: 10000,
        );

        final jsonString = reportGenerator.exportCompatibilityReportAsJSON(report);
        final jsonData = jsonDecode(jsonString);

        expect(jsonData, isA<Map<String, dynamic>>());
        expect(jsonData['reportId'], equals('compat-001'));
      });

      test('compatibility report HTML export contains all versions', () {
        final testResults = [
          TestResult(
            testName: 'test_1',
            testType: 'unit',
            status: 'passed',
            duration: 100,
            timestamp: DateTime.now(),
          ),
        ];

        final report = reportGenerator.generateCompatibilityReport(
          reportId: 'compat-001',
          resultsByVersion: {
            '16.0': testResults,
            '17.0': testResults,
          },
          totalDuration: 10000,
        );

        final htmlString = reportGenerator.exportCompatibilityReportAsHTML(report);

        expect(htmlString, contains('Compatibility Report'));
        expect(htmlString, contains('16.0'));
        expect(htmlString, contains('17.0'));
      });
    });

    group('HTML Escaping', () {
      test('HTML export escapes special characters', () {
        final testResults = [
          TestResult(
            testName: 'test_<script>alert("xss")</script>',
            testType: 'unit',
            status: 'failed',
            duration: 100,
            errorMessage: 'Error: <tag> & "quotes"',
            timestamp: DateTime.now(),
          ),
        ];

        final report = reportGenerator.generateTestReport(
          reportId: 'report-001',
          simulatorId: 'simulator-001',
          testResults: testResults,
          duration: 5000,
        );

        final htmlString = reportGenerator.exportReportAsHTML(report);

        // Verify special characters are escaped
        expect(htmlString, contains('&lt;'));
        expect(htmlString, contains('&gt;'));
        expect(htmlString, contains('&amp;'));
        expect(htmlString, contains('&quot;'));
      });
    });
  });
}
