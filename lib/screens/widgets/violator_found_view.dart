import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/incident_report.dart';

class ViolatorFoundView extends StatelessWidget {
  final QueryDocumentSnapshot violatorSnapshot;
  final List<IncidentReport> incidentReports;
  final VoidCallback onIssueWarning;
  final VoidCallback onIssueFine;
  final Function(IncidentReport) onTapIncident;

  const ViolatorFoundView({
    super.key,
    required this.violatorSnapshot,
    required this.incidentReports,
    required this.onIssueWarning,
    required this.onIssueFine,
    required this.onTapIncident,
  });

  @override
  Widget build(BuildContext context) {
    final data = violatorSnapshot.data() as Map<String, dynamic>;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Violator Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            Text(
              'Name: ${data['full_name']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Address: ${data['address']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Mobile: ${data['mobile_number']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'NIC: ${data['national_id_number']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text(
              'Incident History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            if (incidentReports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('No prior incidents found.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: incidentReports.length,
                itemBuilder: (context, index) {
                  final report = incidentReports[index];
                  final formattedDate = DateFormat.yMMMd().format(report.date);

                  String title = '${report.status} on $formattedDate';
                  String subtitle = 'Recorded by: ${report.officerName}';
                  Color statusColor = report.status == 'Warning'
                      ? Colors.orange
                      : Colors.red;

                  if (report.status == 'Fine' && report.fineAmount != null) {
                    title =
                        'Fine: ${report.fineAmount!.toStringAsFixed(2)} LKR';
                    subtitle =
                        'Status: ${report.paymentStatus ?? 'Unknown'} - on $formattedDate';
                    statusColor = report.paymentStatus == 'Paid'
                        ? Colors.green
                        : Colors.red;
                  }

                  return ListTile(
                    leading: Icon(
                      report.status == 'Warning'
                          ? Icons.warning_amber_rounded
                          : Icons.receipt_long,
                      color: statusColor,
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitle),
                    onTap: () {
                      onTapIncident(report);
                    },
                  );
                },
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onIssueWarning,
                  icon: const Icon(Icons.warning),
                  label: const Text('Issue Warning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: onIssueFine,
                  icon: const Icon(Icons.receipt),
                  label: const Text('Issue Fine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
