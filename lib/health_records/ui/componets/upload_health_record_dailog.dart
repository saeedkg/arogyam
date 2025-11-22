import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../_shared/ui/app_colors.dart';
import '../../controller/health_records_controller.dart';

class UploadRecordDialog extends StatefulWidget {
  @override
  State<UploadRecordDialog> createState() => _UploadRecordDialogState();
}

class _UploadRecordDialogState extends State<UploadRecordDialog> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'General';
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _categories = [
    'General',
    'Lab Report',
    'X-Ray',
    'Prescription',
    'Scan Report',
    'Blood Test',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file');
    }
  }

  Future<void> _uploadRecord() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a title');
      return;
    }

    if (_selectedFile == null) {
      Get.snackbar('Error', 'Please select a file');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final controller = Get.find<HealthRecordsController>();
      await controller.api.uploadHealthRecord(
        file: _selectedFile!,
        title: _titleController.text,
        category: _selectedCategory,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await controller.refreshRecords();

      if (mounted) {
        Get.back();
        Get.snackbar('Success', 'Health record uploaded successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload record: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Upload Health Record',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Field
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter record title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              // File Picker
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: _selectedFile != null ? AppColors.primaryGreen.withValues(alpha: 0.05) : Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.attach_file_rounded,
                        color: _selectedFile != null ? AppColors.primaryGreen : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _selectedFile != null
                            ? Text(
                          _selectedFile!.path.split('/').last,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : Text(
                          'Select File',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Upload',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}