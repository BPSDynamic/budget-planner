import 'dart:convert';
import 'models/test_report.dart';
import 'models/build_report.dart';
import 'models/test_result.dart';

/// Generates comprehensive test and build reports
class ReportGenerator {
  /// Generate a test report from test results
  TestReport generateTestReport({
    required String reportId,
    required String simulatorId,
    required List<TestResult> testResults,
    required int duration,
  }) {
    final totalTests = testResults.length;
    final passedTests = testResults.where((r) => r.status == 'passed').length;
    final failedTests = testResults.where((r) => r.status == 'failed').length;
    final skippedTests = testResults.where((r) => r.status == 'skipped').length;

    return TestReport(
      reportId: reportId,
      simulatorId: simulatorId,
      totalTests: totalTests,
      passedTests: passedTests,
      failedTests: failedTests,
      skippedTests: skippedTests,
      duration: duration,
      testResults: testResults,
      timestamp: DateTime.now(),
    );
  }

  /// Generate a build report with build metrics
  BuildReport generateBuildReport({
    required String buildId,
    required String status,
    required int duration,
    String? artifactPath,
    required int dependencyCount,
    required int cacheHitCount,
  }) {
    return BuildReport(
      buildId: buildId,
      status: status,
      duration: duration,
      artifactPath: artifactPath,
      dependencyCount: dependencyCount,
      cacheHitCount: cacheHitCount,
      timestamp: DateTime.now(),
    );
  }

  /// Generate a compatibility report for multi-version results
  Map<String, dynamic> generateCompatibilityReport({
    required String reportId,
    required Map<String, List<TestResult>> resultsByVersion,
    required int totalDuration,
  }) {
    final versionReports = <String, Map<String, dynamic>>{};

    for (final entry in resultsByVersion.entries) {
      final version = entry.key;
      final results = entry.value;

      final totalTests = results.length;
      final passedTests = results.where((r) => r.status == 'passed').length;
      final failedTests = results.where((r) => r.status == 'failed').length;
      final skippedTests = results.where((r) => r.status == 'skipped').length;

      versionReports[version] = {
        'totalTests': totalTests,
        'passedTests': passedTests,
        'failedTests': failedTests,
        'skippedTests': skippedTests,
        'passRate': totalTests > 0 ? (passedTests / totalTests * 100).toStringAsFixed(2) : '0.00',
        'failedTestNames': results
            .where((r) => r.status == 'failed')
            .map((r) => r.testName)
            .toList(),
      };
    }

    return {
      'reportId': reportId,
      'timestamp': DateTime.now().toIso8601String(),
      'totalDuration': totalDuration,
      'versionReports': versionReports,
      'summary': {
        'totalVersions': resultsByVersion.length,
        'allVersionsPassed': resultsByVersion.values.every(
          (results) => results.every((r) => r.status == 'passed' || r.status == 'skipped'),
        ),
      },
    };
  }

  /// Export test report as JSON string
  String exportReportAsJSON(TestReport report) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(report.toMap());
  }

  /// Export build report as JSON string
  String exportBuildReportAsJSON(BuildReport report) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(report.toMap());
  }

  /// Export compatibility report as JSON string
  String exportCompatibilityReportAsJSON(Map<String, dynamic> report) {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(report);
  }

  /// Export test report as HTML string
  String exportReportAsHTML(TestReport report) {
    final passRate = report.totalTests > 0
        ? ((report.passedTests / report.totalTests) * 100).toStringAsFixed(2)
        : '0.00';

    final failedTestsHtml = report.testResults
        .where((r) => r.status == 'failed')
        .map((r) => '''
      <tr>
        <td>${_escapeHtml(r.testName)}</td>
        <td>${_escapeHtml(r.testType)}</td>
        <td>${r.duration}ms</td>
        <td>${_escapeHtml(r.errorMessage ?? 'N/A')}</td>
      </tr>
    ''')
        .join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Test Report - ${report.reportId}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
    .summary-item { display: inline-block; margin-right: 30px; }
    .passed { color: green; font-weight: bold; }
    .failed { color: red; font-weight: bold; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    tr:nth-child(even) { background-color: #f9f9f9; }
  </style>
</head>
<body>
  <h1>Test Report</h1>
  <p><strong>Report ID:</strong> ${_escapeHtml(report.reportId)}</p>
  <p><strong>Simulator ID:</strong> ${_escapeHtml(report.simulatorId)}</p>
  <p><strong>Timestamp:</strong> ${report.timestamp}</p>
  <p><strong>Duration:</strong> ${report.duration}ms</p>
  
  <div class="summary">
    <div class="summary-item"><strong>Total Tests:</strong> ${report.totalTests}</div>
    <div class="summary-item"><span class="passed">Passed: ${report.passedTests}</span></div>
    <div class="summary-item"><span class="failed">Failed: ${report.failedTests}</span></div>
    <div class="summary-item"><strong>Skipped:</strong> ${report.skippedTests}</div>
    <div class="summary-item"><strong>Pass Rate:</strong> $passRate%</div>
  </div>
  
  ${failedTestsHtml.isNotEmpty ? '''
  <h2>Failed Tests</h2>
  <table>
    <tr>
      <th>Test Name</th>
      <th>Type</th>
      <th>Duration</th>
      <th>Error Message</th>
    </tr>
    $failedTestsHtml
  </table>
  ''' : '<p>All tests passed!</p>'}
</body>
</html>
    ''';
  }

  /// Export build report as HTML string
  String exportBuildReportAsHTML(BuildReport report) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Build Report - ${report.buildId}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
    .summary-item { display: inline-block; margin-right: 30px; }
    .success { color: green; font-weight: bold; }
    .failure { color: red; font-weight: bold; }
  </style>
</head>
<body>
  <h1>Build Report</h1>
  <p><strong>Build ID:</strong> ${_escapeHtml(report.buildId)}</p>
  <p><strong>Status:</strong> <span class="${report.status == 'success' ? 'success' : 'failure'}">${_escapeHtml(report.status)}</span></p>
  <p><strong>Timestamp:</strong> ${report.timestamp}</p>
  <p><strong>Duration:</strong> ${report.duration}ms</p>
  
  <div class="summary">
    <div class="summary-item"><strong>Dependencies:</strong> ${report.dependencyCount}</div>
    <div class="summary-item"><strong>Cache Hits:</strong> ${report.cacheHitCount}</div>
    ${report.artifactPath != null ? '<div class="summary-item"><strong>Artifact:</strong> ${_escapeHtml(report.artifactPath!)}</div>' : ''}
  </div>
</body>
</html>
    ''';
  }

  /// Export compatibility report as HTML string
  String exportCompatibilityReportAsHTML(Map<String, dynamic> report) {
    final versionReports = report['versionReports'] as Map<String, dynamic>;
    final summary = report['summary'] as Map<String, dynamic>;

    final versionRowsHtml = versionReports.entries
        .map((entry) {
          final version = entry.key;
          final versionData = entry.value as Map<String, dynamic>;
          final passRate = versionData['passRate'] as String;
          final allPassed = versionData['failedTestNames'] is List &&
              (versionData['failedTestNames'] as List).isEmpty;

          return '''
      <tr>
        <td>${_escapeHtml(version)}</td>
        <td>${versionData['totalTests']}</td>
        <td>${versionData['passedTests']}</td>
        <td>${versionData['failedTests']}</td>
        <td>${versionData['skippedTests']}</td>
        <td style="color: ${allPassed ? 'green' : 'red'}; font-weight: bold;">$passRate%</td>
      </tr>
    ''';
        })
        .join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <title>Compatibility Report - ${report['reportId']}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h1 { color: #333; }
    .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
    tr:nth-child(even) { background-color: #f9f9f9; }
  </style>
</head>
<body>
  <h1>Multi-Version Compatibility Report</h1>
  <p><strong>Report ID:</strong> ${_escapeHtml(report['reportId'] as String)}</p>
  <p><strong>Timestamp:</strong> ${report['timestamp']}</p>
  <p><strong>Total Duration:</strong> ${report['totalDuration']}ms</p>
  
  <div class="summary">
    <div><strong>Total Versions Tested:</strong> ${summary['totalVersions']}</div>
    <div><strong>All Versions Passed:</strong> ${summary['allVersionsPassed'] == true ? 'Yes' : 'No'}</div>
  </div>
  
  <h2>Version Results</h2>
  <table>
    <tr>
      <th>iOS Version</th>
      <th>Total Tests</th>
      <th>Passed</th>
      <th>Failed</th>
      <th>Skipped</th>
      <th>Pass Rate</th>
    </tr>
    $versionRowsHtml
  </table>
</body>
</html>
    ''';
  }

  /// Helper method to escape HTML special characters
  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
