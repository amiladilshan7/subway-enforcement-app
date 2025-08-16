// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentReport {
  final String incidentId;
  final String status;
  final DateTime date;
  final String officerName;

  // Optional fields for fines
  final double? fineAmount;
  final String? paymentStatus;
  final String? paymentUrl;

  IncidentReport({
    required this.incidentId,
    required this.status,
    required this.date,
    required this.officerName,
    this.fineAmount,
    this.paymentStatus,
    this.paymentUrl,
  });
}
