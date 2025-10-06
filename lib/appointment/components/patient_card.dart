import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String dob;
  final String id;
  final String imageUrl;
  final VoidCallback onChange;
  const PatientCard({required this.name, required this.dob, required this.id, required this.imageUrl, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(Icons.cake_rounded, 'DOB: $dob'),
                    const SizedBox(height: 4),
                    _buildInfoItem(Icons.badge_rounded, 'ID: $id'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 40,
            child: OutlinedButton(
              onPressed: onChange,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF22C58B),
                side: const BorderSide(color: Color(0xFF22C58B), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}