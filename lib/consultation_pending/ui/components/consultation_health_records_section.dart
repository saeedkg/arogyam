import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../health_records/entities/health_record.dart';
import '../../../health_records/ui/health_record_viewer_screen.dart';
import '../../../_shared/ui/app_colors.dart';

class ConsultationHealthRecordsSection extends StatelessWidget {
  final List<HealthRecord> healthRecords;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const ConsultationHealthRecordsSection({
    super.key,
    required this.healthRecords,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show section if no records and not loading
    if (healthRecords.isEmpty && !isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          // Content
          if (isLoading && healthRecords.isEmpty)
            _buildLoadingState()
          else if (error != null && healthRecords.isEmpty)
            _buildErrorState()
          else if (healthRecords.isNotEmpty)
            _buildRecordsList()
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.folder_shared_outlined,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                if (healthRecords.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${healthRecords.length} document${healthRecords.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(8),
                shape: const CircleBorder(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load documents',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRefresh != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRefresh,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No documents shared yet',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...healthRecords.map((record) => _HealthRecordCard(record: record)),
        ],
      ),
    );
  }
}

class _HealthRecordCard extends StatelessWidget {
  final HealthRecord record;

  const _HealthRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToViewer(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // File Icon
                _buildFileIcon(),
                const SizedBox(width: 16),
                
                // File Info
                Expanded(
                  child: _buildFileInfo(),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getFileTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getFileTypeIcon(),
        color: _getFileTypeColor(),
        size: 22,
      ),
    );
  }

  Widget _buildFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // File metadata
        Row(
          children: [
            Text(
              _getFileTypeLabel(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (record.displayFileSize.isNotEmpty) ...[
              Text(
                ' • ${record.displayFileSize}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        
        // Description if available
        if (record.notes != null && record.notes!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            record.notes!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  IconData _getFileTypeIcon() {
    if (record.isImage) {
      return Icons.image_outlined;
    } else if (record.isPdf) {
      return Icons.picture_as_pdf_outlined;
    } else {
      return Icons.description_outlined;
    }
  }

  Color _getFileTypeColor() {
    if (record.isImage) {
      return Colors.blue.shade600;
    } else if (record.isPdf) {
      return Colors.red.shade600;
    } else {
      return Colors.grey.shade600;
    }
  }

  String _getFileTypeLabel() {
    if (record.isImage) {
      return 'Image';
    } else if (record.isPdf) {
      return 'PDF Document';
    } else {
      return 'Document';
    }
  }

  void _navigateToViewer() {
    // Navigate directly to HealthRecordViewerScreen with the record object
    Get.to(() => HealthRecordViewerScreen(healthRecord: record));
  }
}