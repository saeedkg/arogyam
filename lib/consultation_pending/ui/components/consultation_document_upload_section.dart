import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import 'upload_document_dialog.dart';

class ConsultationDocumentUploadSection extends StatelessWidget {
  final String appointmentId;
  final VoidCallback? onDocumentUploaded;

  const ConsultationDocumentUploadSection({
    super.key,
    required this.appointmentId,
    this.onDocumentUploaded,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          // Header Section
          _buildHeader(),
          
          // Content Section
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.05),
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
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.upload_file_outlined,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upload medical reports, test results, or photos',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Upload Benefits
          Row(
            children: [
              Expanded(
                child: _UploadBenefit(
                  icon: Icons.speed_outlined,
                  title: 'Faster Diagnosis',
                  subtitle: 'Help doctor understand your condition',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _UploadBenefit(
                  icon: Icons.security_outlined,
                  title: 'Secure & Private',
                  subtitle: 'Your documents are encrypted',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Upload Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showUploadDialog(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: AppColors.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => UploadDocumentDialog(
        appointmentId: appointmentId,
      ),
    );

    if (result == true && onDocumentUploaded != null) {
      // Document uploaded successfully - notify parent
      onDocumentUploaded!();
    }
  }
}

class _UploadBenefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UploadBenefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}