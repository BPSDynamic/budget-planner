# Design Document: Household Budget Management with Historical & Forecast Views

## Overview

The Household Budget Management feature extends the existing budget app with comprehensive multi-year financial tracking and forecasting capabilities. The system will maintain up to 5 years of historical transaction data, provide sophisticated visualization of spending patterns across years, enable budget category management with variance tracking, and establish a foundation for future forecast functionality. The design emphasizes data integrity, performance optimization through caching, and extensibility for forecast features.

## Architecture

The feature follows a layered architecture:

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                              │
│  (Historical Views, Charts, Category Management)         │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│              Provider/State Management                   │
│  (BudgetProvider, HistoricalDataProvider,               │
│   ForecastProvider, CategoryProvider)                    │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│              Business Logic Layer                        │
│  (Aggregation, Calculations, Validation)                │
└──────────────────┬──────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────┐
│              Data Access Layer                           │
│  (SharedPreferences, Serialization/Deserialization)     │
└─────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. Historical Data Manager
- **Responsibility**: Manage transaction data spanning up to 5 years
- **Key Methods**:
  - `getTransactionsByDateRange(startDate, endDate)`: Returns transactions within specified range
  - `validateTransactionDate(date)`: Ensures date is within 5-year window
  - `getTransactionsForYear(year)`: Returns all transactions for a specific year
  - `getTransactionsForMonth(year, month)`: Returns transactions for specific month

### 2. Data Aggregator
- **Responsibility**: Aggregate transaction data for analysis and visualization
- **Key Methods**:
  - `aggregateByMonth(transactions)`: Groups transactions by month, calculates totals
  - `aggregateByCategory(transactions, period)`: Sums transactions by category for period
  - `calculateYearOverYearGrowth(category, year1, year2)`: Computes growth rate
  - `getCachedAggregation(key)`: Retrieves cached aggregation results
  - `cacheAggregation(key, data)`: Stores aggregation results with TTL

### 3. Budget Category Manager
- **Responsibility**: Manage budget categories and variance tracking
- **Key Methods**:
  - `createCategory(name, description, monthlyLimit)`: Creates new budget category
  - `updateCategoryLimit(categoryId, newLimit)`: Updates budget limit and recalculates variances
  - `calculateVariance(categoryId, period)`: Computes (actual - budget) for category
  - `getCategoryDetails(categoryId)`: Returns category with all metrics
  - `assignTransactionToCategory(transactionId, categoryId)`: Links transaction to category

### 4. Forecast Manager
- **Responsibility**: Store and manage forecast data (foundation for future features)
- **Key Methods**:
  - `createForecast(period, category, amount, assumptions)`: Creates forecast entry
  - `validateForecast(forecast)`: Ensures positive amounts and future periods
  - `deleteForecast(forecastId)`: Removes forecast and updates dependent calculations
  - `getForecastsByPeriod(period)`: Returns forecasts for specific period
  - `getForecastsByCategory(category)`: Returns forecasts for specific category

### 5. Serialization Service
- **Responsibility**: Handle JSON serialization/deserialization with validation
- **Key Methods**:
  - `serializeBudgetData(budgetData)`: Converts to JSON with all fields
  - `deserializeBudgetData(jsonString)`: Reconstructs objects from JSON
  - `serializeForecasts(forecasts)`: Converts forecast list to JSON
  - `deserializeForecasts(jsonString)`: Reconstructs forecast objects
  - `validateDeserializedData(data)`: Ensures all fields present and correctly typed

## Data Models

### BudgetCategory
```
{
  id: String (UUID)
  name: String
  description: String
  monthlyLimit: double
  createdDate: DateTime
  transactions: List<Transaction>
}
```

### Forecast
```
{
  id: String (UUID)
  period: String (YYYY-MM format)
  category: String
  projectedAmount: double
  assumptions: String
  createdDate: DateTime
}
```

### AggregatedData
```
{
  period: String (month/year identifier)
  totalIncome: double
  totalExpense: double
  byCategory: Map<String, double>
  byMonth: Map<String, AggregatedData>
}
```

### HistoricalSummary
```
{
  year: int
  monthlyTotals: Map<int, {income: double, expense: double}>
  categoryTotals: Map<String, double>
  yearOverYearGrowth: Map<String, double>
}
```

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Historical Data Range Validation
*For any* transaction loaded from storage, the transaction date SHALL fall within the 5-year historical window (current date minus 5 years to current date).
**Validates: Requirements 1.5**

### Property 2: Date Range Filtering Completeness
*For any* date range filter applied to transactions, all returned transactions SHALL have dates within the specified range, and no transactions with dates outside the range SHALL be included.
**Validates: Requirements 1.2**

### Property 3: Monthly Aggregation Accuracy
*For any* set of transactions aggregated by month, the sum of all category totals for that month SHALL equal the total spending for that month.
**Validates: Requirements 6.5**

### Property 4: Category Aggregation Correctness
*For any* category and time period, the sum of all transactions assigned to that category for the period SHALL equal the reported category total.
**Validates: Requirements 6.2**

### Property 5: Budget Variance Calculation
*For any* budget category with actual spending and budget limit, the variance SHALL be calculated as (actual spending - budget limit), with positive values indicating overspending and negative values indicating underspending.
**Validates: Requirements 3.5**

### Property 6: Year-over-Year Growth Calculation
*For any* spending category with data in consecutive years, the year-over-year growth rate SHALL be calculated as ((current year total - previous year total) / previous year total) * 100, producing accurate percentage values.
**Validates: Requirements 2.2**

### Property 7: Budget Category Persistence
*For any* budget category created and saved, retrieving the category from storage SHALL return an equivalent category with identical name, description, and monthly limit.
**Validates: Requirements 3.1**

### Property 8: Forecast Data Validation
*For any* forecast entry, the projected amount SHALL be a positive number and the forecast period SHALL be in the future (after current date).
**Validates: Requirements 4.5**

### Property 9: Forecast Persistence
*For any* forecast created and saved, retrieving the forecast from storage SHALL return an equivalent forecast with identical period, category, amount, and assumptions.
**Validates: Requirements 4.1**

### Property 10: Serialization Round Trip
*For any* budget data (categories, transactions, forecasts) serialized to JSON and then deserialized, the reconstructed data SHALL be equivalent to the original data before serialization.
**Validates: Requirements 5.5**

### Property 11: Forecast Data Separation
*For any* forecast stored in the system, it SHALL be stored separately from historical transaction data and SHALL not appear in transaction queries.
**Validates: Requirements 4.2**

### Property 12: Category Variance Recalculation
*For any* budget category where the monthly limit is modified, all variance calculations for that category SHALL be recalculated to reflect the new limit.
**Validates: Requirements 3.4**

### Property 13: Date Range Preference Persistence
*For any* date range selected by a user, saving the preference and loading it in a new session SHALL return the same date range.
**Validates: Requirements 1.4**

### Property 14: Aggregation Caching Consistency
*For any* aggregation query performed twice with identical parameters, the cached result from the second query SHALL be equivalent to the result from the first query.
**Validates: Requirements 6.3**

### Property 15: Decimal Precision
*For any* calculated financial value (variance, growth rate, percentage), the result SHALL be accurate to exactly two decimal places.
**Validates: Requirements 2.5**

## Error Handling

- **Invalid Date Ranges**: Return empty list and log warning if end date is before start date
- **Out-of-Range Transactions**: Silently exclude transactions outside 5-year window during load
- **Invalid Forecast Data**: Reject forecasts with negative amounts or past periods with validation error
- **Deserialization Failures**: Catch JSON parsing errors and return default empty data structures
- **Missing Fields**: Validate all required fields present during deserialization; fail gracefully with error message
- **Category Not Found**: Return null or empty result when querying non-existent categories
- **Concurrent Modifications**: Use immutable data structures to prevent race conditions during aggregation

## Testing Strategy

### Unit Testing
- Test individual calculation functions (variance, growth rate, aggregation)
- Test date range validation logic
- Test serialization/deserialization of each data model
- Test category creation and modification
- Test forecast validation rules

### Property-Based Testing
The system will use **fast-check** (or equivalent Dart property testing library) for property-based testing with minimum 100 iterations per property:

- **Property 1-15**: Each property will have a dedicated property-based test
- **Test Generators**: 
  - Transaction generator: Creates transactions with random dates within 5-year window
  - Category generator: Creates categories with valid names and positive budget limits
  - Forecast generator: Creates forecasts with future dates and positive amounts
  - Date range generator: Creates valid date ranges within 5-year window
- **Test Annotation Format**: Each test will be tagged with `**Feature: household-budget-management, Property {N}: {property_text}**`
- **Assertion Strategy**: Tests will verify properties hold across 100+ randomly generated inputs

### Integration Testing
- Test end-to-end flow: create category → add transactions → calculate variance → verify persistence
- Test multi-year data loading and aggregation
- Test forecast creation and separation from transactions
- Test date range filtering with real transaction data

