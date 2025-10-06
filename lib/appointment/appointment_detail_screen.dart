import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../landing/service/mock_api_service.dart';
import 'entities/booking_detail.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final String bookingId;
  const AppointmentDetailScreen({super.key, required this.bookingId});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _api = MockApiService();
  Future<BookingDetail>? _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchBookingDetail(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: Get.back),
        title: const Text('Appointment Details', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))],
      ),
      body: FutureBuilder<BookingDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(d.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            Text(d.specialization, style: const TextStyle(color: Colors.black87)),
                            Text(d.hospital, style: const TextStyle(color: Colors.black54)),
                            const Divider(height: 24),
                            Row(children: [
                              const Icon(Icons.event, size: 16),
                              const SizedBox(width: 6),
                              Text(_formatDate(d.startTime)),
                            ]),
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.access_time, size: 16),
                              const SizedBox(width: 6),
                              Text('${_formatTime(d.startTime)} - ${_formatTime(d.endTime)}'),
                            ]),
                            const SizedBox(height: 8),
                            Text(d.status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Prescription', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('Status: ${d.prescriptionAvailable ? 'Available' : 'Not available'}'),
                      if (d.prescriptionAvailable && d.prescriptionUrl != null) ...[
                        const SizedBox(height: 8),
                        Text(maxLines: 1,'File: ${d.prescriptionUrl}', style: const TextStyle(color: Colors.blue)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Add download functionality here
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download Prescription'),
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Summary', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      _row('Amount Paid:', '₹ ${d.amountPaid.toStringAsFixed(2)}'),
                      const SizedBox(height: 6),
                      _row('Status:', d.paymentStatus),
                      const SizedBox(height: 6),
                      _row('Transaction ID:', d.transactionId),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Add download functionality here
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download Receipt'),
                          style: OutlinedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.headset_mic_rounded),
                  label: const Text('Contact Support'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF22C58B),
                    shape: const StadiumBorder(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(left, style: const TextStyle(color: Colors.black54)), Text(right, style: const TextStyle(fontWeight: FontWeight.w700))],
    );
  }

  String _formatDate(DateTime dt) => '${_month(dt.month)} ${dt.day}, ${dt.year}';
  String _formatTime(DateTime dt) => '${_pad(dt.hour)}:${_pad(dt.minute)} ${dt.hour >= 12 ? 'PM' : 'AM'}';
  String _pad(int n) => n.toString().padLeft(2, '0');
  String _month(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: child,
    );
  }
}

