import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../_shared/ui/app_colors.dart';
import '../service/prescription_service.dart';

class PrescriptionViewerScreen extends StatefulWidget {
  final String prescriptionUrl;
  final String prescriptionId;
  final String doctorName;

  const PrescriptionViewerScreen({
    super.key,
    required this.prescriptionUrl,
    required this.prescriptionId,
    required this.doctorName,
  });

  @override
  State<PrescriptionViewerScreen> createState() => _PrescriptionViewerScreenState();
}

class _PrescriptionViewerScreenState extends State<PrescriptionViewerScreen> {
  final _prescriptionService = PrescriptionService();
  PDFViewController? _pdfViewController;
  
  // State management
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _localFilePath;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPrescription();
  }

  @override
  void dispose() {
    _pdfViewController = null;
    super.dispose();
  }

  Future<void> _loadPrescription() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final filePath = await _prescriptionService.fetchPrescriptionForViewing(
        prescriptionUrl: widget.prescriptionUrl,
        prescriptionId: widget.prescriptionId,
        onProgress: (received, total) {
          // Optional: could show progress here
        },
      );

      if (filePath != null) {
        if (mounted) {
          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Failed to load prescription. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Unable to load prescription. Please check your internet connection.';
    } else if (errorString.contains('permission')) {
      return 'Unable to save file. Please check storage permissions.';
    } else if (errorString.contains('auth') || errorString.contains('token')) {
      return 'Session expired. Please log in again.';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Prescription not available. Please contact support.';
    } else {
      return 'Unable to load prescription. Please try again.';
    }
  }

  Future<void> _downloadPrescription() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final fileName = 'prescription_${widget.prescriptionId}.pdf';
      
      final success = await _prescriptionService.downloadPrescriptionPermanently(
        prescriptionUrl: widget.prescriptionUrl,
        fileName: fileName,
        onProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Prescription downloaded successfully'),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Failed to download prescription'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _downloadPrescription,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Error: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _downloadPrescription,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _sharePrescription() async {
    if (_localFilePath == null) return;

    try {
      final xFile = XFile(_localFilePath!);
      await Share.shareXFiles(
        [xFile],
        subject: 'Prescription - Dr. ${widget.doctorName}',
        text: 'Sharing prescription from Dr. ${widget.doctorName}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Failed to share prescription: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _loadPrescription();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDownloading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isDownloading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Please wait for download to complete'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Prescription - Dr. ${widget.doctorName}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: _isDownloading ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            onPressed: _isDownloading || _localFilePath == null ? null : _downloadPrescription,
          ),
          IconButton(
            icon: Icon(
              Icons.share_rounded,
              color: _localFilePath == null ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            onPressed: _localFilePath == null ? null : _sharePrescription,
          ),
        ],
      ),
      body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return _buildPdfViewer();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Loading prescription...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Unable to Load Prescription',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'There was a problem loading the prescription. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.infoBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (_localFilePath == null) {
      return Center(
        child: Text(
          'No prescription file available',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // PDF viewer
        Container(
          color: Colors.white,
          child: PDFView(
            filePath: _localFilePath!,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
              });
            },
            onError: (error) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Unable to display PDF. The file may be corrupted.';
              });
            },
            onPageError: (page, error) {
              print('Error on page $page: $error');
            },
            onViewCreated: (PDFViewController controller) {
              _pdfViewController = controller;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            },
          ),
        ),
        
        // Page indicator overlay
        if (_totalPages > 0)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
