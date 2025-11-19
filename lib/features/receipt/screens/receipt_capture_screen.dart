import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:budget_planner/core/theme/app_colors.dart';
import 'receipt_review_screen.dart';

class ReceiptCaptureScreen extends StatefulWidget {
  const ReceiptCaptureScreen({super.key});

  @override
  State<ReceiptCaptureScreen> createState() => _ReceiptCaptureScreenState();
}

class _ReceiptCaptureScreenState extends State<ReceiptCaptureScreen> {
  bool _isProcessing = false;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        _processReceiptImage(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera: $e')),
        );
      }
    }
  }

  Future<void> _uploadFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _processReceiptImage(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing gallery: $e')),
        );
      }
    }
  }

  void _processReceiptImage(XFile image) {
    setState(() {
      _isProcessing = true;
    });

    // Simulate OCR processing delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Mock extracted data from receipt
        final mockExtractedData = {
          'merchant': 'Whole Foods Market',
          'amount': 45.99,
          'date': DateTime.now(),
          'category': 'Groceries',
          'items': [
            {'description': 'Organic Apples', 'price': 5.99},
            {'description': 'Almond Milk', 'price': 4.49},
            {'description': 'Bread', 'price': 3.99},
            {'description': 'Cheese', 'price': 8.99},
            {'description': 'Vegetables', 'price': 22.54},
          ],
          'confidence': 0.87,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptReviewScreen(
              extractedData: mockExtractedData,
            ),
          ),
        );

        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera Preview Placeholder
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position receipt in frame',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips for best results:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Ensure good lighting'),
                  _buildTip('Keep receipt flat and straight'),
                  _buildTip('Include the total amount'),
                  _buildTip('Avoid shadows and glare'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Capture Button
            FilledButton.icon(
              onPressed: _isProcessing ? null : _captureFromCamera,
              icon: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(
                _isProcessing ? 'Processing Receipt...' : 'Capture Receipt',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Upload from Gallery Button
            OutlinedButton.icon(
              onPressed: _isProcessing ? null : _uploadFromGallery,
              icon: const Icon(Icons.image),
              label: const Text(
                'Upload from Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
