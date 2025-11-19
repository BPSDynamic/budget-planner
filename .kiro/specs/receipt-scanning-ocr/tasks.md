# Implementation Plan: Receipt Scanning & OCR

- [ ] 1. Set up receipt scanning infrastructure
  - Add image_picker dependency for camera and gallery access
  - Add google_mlkit_text_recognition for OCR processing
  - Create directory structure: `lib/features/receipt/models/`, `lib/features/receipt/services/`, `lib/features/receipt/screens/`
  - Set up platform-specific permissions (iOS, Android, Web)
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 2. Implement Receipt Image Models
  - Create `ReceiptImage` model with serialization (toMap/fromMap)
  - Create `ExtractedReceiptData` model with all fields and confidence scores
  - Create `ReceiptReviewData` model for user review workflow
  - Add equality operators and hashCode for testing
  - _Requirements: 1.1, 2.1, 2.2_

- [ ]* 2.1 Write property test for ReceiptImage serialization
  - **Property 7: Receipt Image Compression**
  - **Validates: Requirements 5.2**

- [ ] 3. Implement Receipt Capture Manager
  - Create `ReceiptCaptureManager` class
  - Implement `captureReceiptFromCamera()` method
  - Implement `uploadReceiptFromGallery()` method
  - Implement `validateReceiptImage(image)` for format and size validation
  - Implement `cropAndRotateImage(image, cropRect, rotation)` method
  - Implement `compressImage(image, maxSize)` method
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ]* 3.1 Write property test for image validation
  - **Property 1: Image Validation Completeness**
  - **Validates: Requirements 1.3**

- [ ] 4. Implement OCR Processor
  - Create `OCRProcessor` class
  - Implement `processReceiptImage(image)` method using ML Kit
  - Implement `extractText(image)` method
  - Implement `calculateConfidenceScore(extractedText)` method
  - Implement `parseReceiptStructure(text)` method
  - Implement `detectMerchantName(text)` method
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [ ]* 4.1 Write property test for amount extraction
  - **Property 2: Amount Extraction Accuracy**
  - **Validates: Requirements 2.3, 6.1**

- [ ]* 4.2 Write property test for date extraction
  - **Property 3: Date Extraction Validity**
  - **Validates: Requirements 3.2, 6.2**

- [ ]* 4.3 Write property test for merchant extraction
  - **Property 4: Merchant Name Extraction**
  - **Validates: Requirements 3.1, 6.3**

- [ ]* 4.4 Write property test for confidence scores
  - **Property 5: Confidence Score Validity**
  - **Validates: Requirements 2.4, 7.2**

- [ ] 5. Implement Receipt Data Extractor
  - Create `ReceiptDataExtractor` class
  - Implement `extractMerchant(text)` method
  - Implement `extractDate(text)` method with date parsing
  - Implement `extractAmount(text)` method with numeric parsing
  - Implement `extractLineItems(text)` method
  - Implement `categorizeTransaction(merchant, items)` method
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 5.1 Write property test for line items extraction
  - **Property 6: Line Items Extraction**
  - **Validates: Requirements 3.4**

- [ ] 6. Implement Receipt Validator
  - Create `ReceiptValidator` class
  - Implement `validateAmount(amount)` method
  - Implement `validateDate(date)` method with 90-day window check
  - Implement `validateMerchant(merchant)` method
  - Implement `validateLineItems(items)` method
  - Implement `validateAllFields(receiptData)` method
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 6.1 Write property test for data validation
  - **Property 9: Data Validation Completeness**
  - **Validates: Requirements 6.1, 6.2, 6.3**

- [ ] 7. Implement Receipt Storage Manager
  - Create `ReceiptStorageManager` class
  - Implement `storeReceiptImage(image, transactionId)` method
  - Implement `retrieveReceiptImage(transactionId)` method
  - Implement `deleteReceiptImage(transactionId)` method
  - Implement `getReceiptMetadata(transactionId)` method
  - Integrate with SharedPreferences for metadata storage
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ]* 7.1 Write property test for receipt-transaction linkage
  - **Property 8: Receipt-Transaction Linkage**
  - **Validates: Requirements 5.1, 5.4**

- [ ] 8. Create Receipt Capture Screen
  - Create `ReceiptCaptureScreen` widget
  - Implement camera capture UI with preview
  - Implement gallery upload option
  - Add crop and rotate controls
  - Display image preview before processing
  - Add "Process Receipt" button
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 9. Create Receipt Review Screen
  - Create `ReceiptReviewScreen` widget
  - Display extracted merchant, date, amount, and line items
  - Highlight low-confidence fields (< 60%)
  - Implement editable fields for user corrections
  - Display confidence scores for each field
  - Add "Confirm & Save" and "Edit Manually" buttons
  - Show receipt image preview
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 10. Create Receipt Entry Choice Screen
  - Create `ReceiptEntryChoiceScreen` widget
  - Display two options: "Scan Receipt" and "Manual Entry"
  - Route to appropriate screen based on user selection
  - _Requirements: 1.1_

- [ ] 11. Integrate Receipt Scanning into Add Transaction Flow
  - Update `AddTransactionScreen` to show entry choice screen
  - Route to receipt capture when "Scan Receipt" selected
  - Route to manual entry when "Manual Entry" selected
  - Pass extracted data to manual entry form if available
  - _Requirements: 1.1, 4.1_

- [ ] 12. Create ReceiptProvider for state management
  - Create `ReceiptProvider` class extending ChangeNotifier
  - Implement `captureReceipt(image)` method
  - Implement `processReceipt(image)` method
  - Implement `updateExtractedData(field, value)` method
  - Implement `saveReceiptTransaction(transaction)` method
  - Implement `getReceiptImage(transactionId)` method
  - _Requirements: 1.1, 2.1, 4.1, 5.1_

- [ ]* 12.1 Write property test for OCR confidence tracking
  - **Property 10: OCR Confidence Tracking**
  - **Validates: Requirements 7.1, 7.2**

- [ ] 13. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 14. Integration testing for receipt scanning flow
  - Test capturing receipt from camera
  - Test uploading receipt from gallery
  - Test image validation and compression
  - Test OCR processing and data extraction
  - Test receipt review and editing
  - Test transaction creation from receipt
  - Test receipt image storage and retrieval
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2_

- [ ] 15. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
