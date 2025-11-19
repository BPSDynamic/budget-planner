# Implementation Plan: Household Budget Management

## Overview
This implementation plan breaks down the household budget management feature into discrete, manageable coding tasks. Each task builds incrementally on previous work, starting with core data models and persistence, then moving to business logic, and finally UI integration.

---

- [x] 1. Set up project structure and core data models
  - Create directory structure: `lib/features/budget/models/`, `lib/features/budget/providers/`, `lib/features/budget/services/`
  - Define `BudgetCategory` model with serialization (toMap/fromMap)
  - Define `Forecast` model with serialization (toMap/fromMap)
  - Define `AggregatedData` model for aggregation results
  - Define `HistoricalSummary` model for multi-year summaries
  - _Requirements: 3.1, 4.1, 5.1_

- [x] 1.1 Write property test for BudgetCategory serialization round trip
  - **Property 7: Budget Category Persistence**
  - **Validates: Requirements 3.1**

- [x] 1.2 Write property test for Forecast serialization round trip
  - **Property 9: Forecast Persistence**
  - **Validates: Requirements 4.1**

- [x] 2. Implement Historical Data Manager
  - Create `HistoricalDataManager` class with methods for date range queries
  - Implement `getTransactionsByDateRange(startDate, endDate)` method
  - Implement `validateTransactionDate(date)` to ensure 5-year window compliance
  - Implement `getTransactionsForYear(year)` method
  - Implement `getTransactionsForMonth(year, month)` method
  - _Requirements: 1.1, 1.2, 1.5_

- [x] 2.1 Write property test for historical data range validation
  - **Property 1: Historical Data Range Validation**
  - **Validates: Requirements 1.5**

- [x] 2.2 Write property test for date range filtering
  - **Property 2: Date Range Filtering Completeness**
  - **Validates: Requirements 1.2**

- [ ] 3. Implement Data Aggregator with caching
  - Create `DataAggregator` class with caching mechanism
  - Implement `aggregateByMonth(transactions)` for monthly grouping
  - Implement `aggregateByCategory(transactions, period)` for category totals
  - Implement `calculateYearOverYearGrowth(category, year1, year2)` method
  - Implement cache storage and retrieval with TTL
  - Implement `getCachedAggregation(key)` and `cacheAggregation(key, data)` methods
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 3.1 Write property test for monthly aggregation accuracy
  - **Property 3: Monthly Aggregation Accuracy**
  - **Validates: Requirements 6.5**

- [ ] 3.2 Write property test for category aggregation correctness
  - **Property 4: Category Aggregation Correctness**
  - **Validates: Requirements 6.2**

- [ ] 3.3 Write property test for year-over-year growth calculation
  - **Property 6: Year-over-Year Growth Calculation**
  - **Validates: Requirements 2.2**

- [ ] 3.4 Write property test for aggregation caching consistency
  - **Property 14: Aggregation Caching Consistency**
  - **Validates: Requirements 6.3**

- [ ] 4. Implement Budget Category Manager
  - Create `BudgetCategoryManager` class
  - Implement `createCategory(name, description, monthlyLimit)` method
  - Implement `updateCategoryLimit(categoryId, newLimit)` method
  - Implement `calculateVariance(categoryId, period)` method with correct formula
  - Implement `getCategoryDetails(categoryId)` method
  - Implement `assignTransactionToCategory(transactionId, categoryId)` method
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 4.1 Write property test for budget variance calculation
  - **Property 5: Budget Variance Calculation**
  - **Validates: Requirements 3.5**

- [ ] 4.2 Write property test for category variance recalculation
  - **Property 12: Category Variance Recalculation**
  - **Validates: Requirements 3.4**

- [ ] 5. Implement Forecast Manager
  - Create `ForecastManager` class
  - Implement `createForecast(period, category, amount, assumptions)` method
  - Implement `validateForecast(forecast)` with positive amount and future period checks
  - Implement `deleteForecast(forecastId)` method
  - Implement `getForecastsByPeriod(period)` method
  - Implement `getForecastsByCategory(category)` method
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 5.1 Write property test for forecast data validation
  - **Property 8: Forecast Data Validation**
  - **Validates: Requirements 4.5**

- [ ] 5.2 Write property test for forecast data separation
  - **Property 11: Forecast Data Separation**
  - **Validates: Requirements 4.2**

- [ ] 6. Implement Serialization Service
  - Create `SerializationService` class
  - Implement `serializeBudgetData(budgetData)` to JSON with all fields
  - Implement `deserializeBudgetData(jsonString)` with validation
  - Implement `serializeForecasts(forecasts)` to JSON
  - Implement `deserializeForecasts(jsonString)` with validation
  - Implement `validateDeserializedData(data)` for field presence and type checking
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 6.1 Write property test for serialization round trip
  - **Property 10: Serialization Round Trip**
  - **Validates: Requirements 5.5**

- [ ] 7. Extend BudgetProvider with new functionality
  - Add `_categories` list to store budget categories
  - Add `_forecasts` list to store forecast entries
  - Add `_dateRangePreference` to store user's selected date range
  - Implement `addCategory(category)` method
  - Implement `deleteCategory(categoryId)` method
  - Implement `addForecast(forecast)` method
  - Implement `deleteForecast(forecastId)` method
  - Implement `setDateRangePreference(startDate, endDate)` method
  - Implement `getDateRangePreference()` method
  - Update `_saveData()` to persist categories, forecasts, and preferences
  - Update `_loadData()` to load categories, forecasts, and preferences
  - _Requirements: 1.4, 4.1, 4.2, 4.3, 4.4_

- [ ] 7.1 Write property test for date range preference persistence
  - **Property 13: Date Range Preference Persistence**
  - **Validates: Requirements 1.4**

- [ ] 8. Implement aggregation data loading in BudgetProvider
  - Add `_aggregatedData` cache to BudgetProvider
  - Implement `getAggregatedDataForPeriod(startDate, endDate)` method
  - Implement `getMonthlyBreakdown(year)` method
  - Implement `getCategoryTotals(period)` method
  - Integrate DataAggregator with BudgetProvider
  - _Requirements: 1.3, 2.1, 2.3, 2.4_

- [ ] 9. Create Historical View Screen
  - Create `HistoricalViewScreen` widget
  - Implement date range picker for 5-year selection
  - Display transaction list filtered by selected date range
  - Show aggregated summary (total income, total expense, balance)
  - Add filter controls for date range adjustment
  - _Requirements: 1.1, 1.2_

- [ ] 10. Create Multi-Year Dashboard Screen
  - Create `MultiYearDashboardScreen` widget
  - Implement year selector (dropdown or tabs for 5 years)
  - Create comparative charts showing income vs expense by year
  - Display year-over-year growth rates for each category
  - Show monthly breakdown for selected year
  - Display category breakdown with percentages
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 10.1 Write property test for decimal precision in calculations
  - **Property 15: Decimal Precision**
  - **Validates: Requirements 2.5**

- [ ] 11. Create Budget Category Management Screen
  - Create `BudgetCategoryScreen` widget
  - Implement category list display with current spending and budget limit
  - Create form for adding new categories
  - Implement category editing (name, description, limit)
  - Implement category deletion with confirmation
  - Display variance for each category (overspending/underspending)
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 12. Create Forecast Management Screen
  - Create `ForecastManagementScreen` widget
  - Implement forecast list display organized by period and category
  - Create form for adding new forecasts
  - Implement forecast editing
  - Implement forecast deletion
  - Display forecast details (period, category, amount, assumptions)
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 13. Integrate new screens into main navigation
  - Update `MainScreen` to include new navigation destinations
  - Add Historical View to bottom navigation
  - Add Multi-Year Dashboard to bottom navigation
  - Add Budget Categories to settings or main navigation
  - Add Forecast Management to settings or main navigation
  - Ensure navigation flow is intuitive
  - _Requirements: 1.1, 2.1, 3.1, 4.1_

- [ ] 14. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 15. Integration testing for end-to-end flows
  - Test creating category → adding transactions → calculating variance
  - Test loading 5-year historical data and filtering by date range
  - Test multi-year aggregation and year-over-year calculations
  - Test forecast creation and separation from transactions
  - Test serialization/deserialization of all data types
  - Test date range preference persistence across sessions
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 16. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

