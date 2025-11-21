import 'dart:convert';
import 'package:budget_planner/features/budget/models/budget_category.dart';
import 'package:budget_planner/features/budget/models/forecast.dart';

class SerializationService {
  /// Serializes budget data (categories) to JSON string
  /// Includes all fields: id, name, description, monthlyLimit, createdDate
  String serializeBudgetData(List<BudgetCategory> categories) {
    final data = categories.map((cat) => cat.toMap()).toList();
    return jsonEncode(data);
  }

  /// Deserializes budget data from JSON string
  /// Validates that all required fields are present
  List<BudgetCategory> deserializeBudgetData(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final categories = <BudgetCategory>[];

      for (final item in decoded) {
        validateDeserializedData(item);
        categories.add(BudgetCategory.fromMap(item as Map<String, dynamic>));
      }

      return categories;
    } catch (e) {
      if (e is FormatException) {
        throw FormatException('Invalid JSON format: $e');
      }
      rethrow;
    }
  }

  /// Serializes forecasts to JSON string
  /// Includes all fields: id, period, category, projectedAmount, assumptions, createdDate
  String serializeForecasts(List<Forecast> forecasts) {
    final data = forecasts.map((forecast) => forecast.toMap()).toList();
    return jsonEncode(data);
  }

  /// Deserializes forecasts from JSON string
  /// Validates that all required fields are present
  List<Forecast> deserializeForecasts(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final forecasts = <Forecast>[];

      for (final item in decoded) {
        validateDeserializedData(item);
        forecasts.add(Forecast.fromMap(item as Map<String, dynamic>));
      }

      return forecasts;
    } catch (e) {
      if (e is FormatException) {
        throw FormatException('Invalid JSON format: $e');
      }
      rethrow;
    }
  }

  /// Validates deserialized data for required fields and correct types
  /// Throws ArgumentError if validation fails
  void validateDeserializedData(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw ArgumentError('Data must be a map');
    }

    // Check for required fields
    final requiredFields = ['id', 'createdDate'];
    for (final field in requiredFields) {
      if (!data.containsKey(field)) {
        throw ArgumentError('Missing required field: $field');
      }
    }

    // Validate field types
    if (data['id'] is! String) {
      throw ArgumentError('Field "id" must be a string');
    }

    if (data['createdDate'] is! String) {
      throw ArgumentError('Field "createdDate" must be a string');
    }

    // Validate createdDate is a valid ISO8601 string
    try {
      DateTime.parse(data['createdDate'] as String);
    } catch (e) {
      throw ArgumentError('Field "createdDate" must be a valid ISO8601 date string');
    }

    // Validate category-specific fields if present
    if (data.containsKey('name') && data['name'] is! String) {
      throw ArgumentError('Field "name" must be a string');
    }

    if (data.containsKey('description') && data['description'] is! String) {
      throw ArgumentError('Field "description" must be a string');
    }

    if (data.containsKey('monthlyLimit')) {
      if (data['monthlyLimit'] is! num) {
        throw ArgumentError('Field "monthlyLimit" must be a number');
      }
      if ((data['monthlyLimit'] as num) <= 0) {
        throw ArgumentError('Field "monthlyLimit" must be positive');
      }
    }

    // Validate forecast-specific fields if present
    if (data.containsKey('period') && data['period'] is! String) {
      throw ArgumentError('Field "period" must be a string');
    }

    if (data.containsKey('category') && data['category'] is! String) {
      throw ArgumentError('Field "category" must be a string');
    }

    if (data.containsKey('projectedAmount')) {
      if (data['projectedAmount'] is! num) {
        throw ArgumentError('Field "projectedAmount" must be a number');
      }
      if ((data['projectedAmount'] as num) <= 0) {
        throw ArgumentError('Field "projectedAmount" must be positive');
      }
    }

    if (data.containsKey('assumptions') && data['assumptions'] is! String) {
      throw ArgumentError('Field "assumptions" must be a string');
    }
  }
}
