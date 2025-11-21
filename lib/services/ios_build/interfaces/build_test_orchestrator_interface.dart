import '../models/build_report.dart';
import '../models/test_report.dart';

/// Abstract interface for orchestrating iOS build and test workflow
abstract class BuildTestOrchestratorInterface {
  /// Run the complete build and test workflow
  Future<Map<String, dynamic>> runFullBuildAndTest();

  /// Validate that all prerequisites are installed and available
  Future<Map<String, bool>> validatePrerequisites();

  /// Execute the workflow steps in sequence
  Future<void> executeWorkflow();

  /// Handle errors with recovery logic
  Future<void> handleErrors(Exception error);

  /// Report the final status of the workflow
  Future<Map<String, dynamic>> reportFinalStatus();
}
