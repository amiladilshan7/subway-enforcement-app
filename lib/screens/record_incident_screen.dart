import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/incident_report.dart';
import 'widgets/violator_found_view.dart';
import 'widgets/add_violator_form.dart';
import '../services/sms_service.dart';

class RecordIncidentScreen extends StatefulWidget {
  const RecordIncidentScreen({super.key});

  @override
  State<RecordIncidentScreen> createState() => _RecordIncidentScreenState();
}

class _RecordIncidentScreenState extends State<RecordIncidentScreen> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final SmsService _smsService = SmsService();

  QueryDocumentSnapshot? _violatorSnapshot;
  List<IncidentReport> _incidentReports = [];
  bool _isLoading = false;
  bool _noResult = false;

  // ---------- Utility ----------
  void _showSnack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  CollectionReference get _violators =>
      FirebaseFirestore.instance.collection('violators');
  CollectionReference get _incidents =>
      FirebaseFirestore.instance.collection('incidents');
  CollectionReference get _fines =>
      FirebaseFirestore.instance.collection('fines');

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  // ---------- Payment ----------
  void _showMarkAsPaidDialog(IncidentReport report) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Mark the fine of ${report.fineAmount?.toStringAsFixed(2)} LKR as PAID?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.of(context).pop();
              _updateFineStatus(report.incidentId);
            },
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFineStatus(String incidentId) async {
    _setLoading(true);
    try {
      final fineDocQuery = await _fines
          .where('incident_id', isEqualTo: incidentId)
          .limit(1)
          .get();
      if (fineDocQuery.docs.isEmpty) return;

      final fineDoc = fineDocQuery.docs.first;
      final fineData = fineDoc.data() as Map<String, dynamic>;

      await _fines.doc(fineDoc.id).update({
        'payment_status': 'Paid',
        'payment_date': Timestamp.now(),
      });

      final fineAmount = (fineData['amount'] as num).toDouble();
      _smsService.sendPaymentConfirmationSms(
        _violatorSnapshot!['mobile_number'],
        fineAmount,
      );

      _showSnack('Fine status updated to PAID.', color: Colors.green);
      await _fetchIncidents(_violatorSnapshot!.id);
    } catch (e) {
      _showSnack('Failed to update status: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Search ----------
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _nameController.clear();
      _addressController.clear();
      _mobileController.clear();
      _violatorSnapshot = null;
      _noResult = false;
      _incidentReports = [];
    });
  }

  Future<void> _searchViolator() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    _setLoading(true);
    _noResult = false;
    _violatorSnapshot = null;
    _incidentReports.clear();

    try {
      final snapshot = await _violators
          .where('national_id_number', isEqualTo: searchTerm)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        _violatorSnapshot = snapshot.docs.first;
        await _fetchIncidents(_violatorSnapshot!.id);
      } else {
        _noResult = true;
      }
    } catch (e) {
      _showSnack('Error searching: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Incidents ----------
  Future<void> _fetchIncidents(String violatorId) async {
    // Step 1: Get all incidents for the violator.
    final incidentsSnapshot = await _incidents
        .where('violator_id', isEqualTo: violatorId)
        .orderBy('incident_date', descending: true)
        .get();

    final incidentDocs = incidentsSnapshot.docs;

    // Step 2: Efficiently find all related fine details in a single batch.
    final fineIncidentIds = incidentDocs
        .where(
          (doc) => (doc.data() as Map<String, dynamic>)['status'] == 'Fine',
        )
        .map((doc) => doc.id)
        .toList();

    final finesMap = <String, Map<String, dynamic>>{};
    if (fineIncidentIds.isNotEmpty) {
      final finesSnapshot = await _fines
          .where('incident_id', whereIn: fineIncidentIds)
          .get();
      for (final doc in finesSnapshot.docs) {
        finesMap[doc['incident_id']] = doc.data() as Map<String, dynamic>;
      }
    }

    // Step 3: Build the final report list using the data we've gathered.
    final reports = incidentDocs.map((incidentDoc) {
      final incidentData = incidentDoc.data() as Map<String, dynamic>;
      final fineData = finesMap[incidentDoc.id];

      return IncidentReport(
        incidentId: incidentDoc.id,
        status: incidentData['status'],
        date: (incidentData['incident_date'] as Timestamp).toDate(),
        officerName: incidentData['officer_name'],
        fineAmount: fineData?['amount'] != null
            ? (fineData!['amount'] as num).toDouble()
            : null,
        paymentStatus: fineData?['payment_status'],
        paymentUrl: fineData?['payment_url'],
      );
    }).toList();

    if (mounted) {
      setState(() {
        _incidentReports = reports;
      });
    }
  }

  Future<void> _saveIncident({
    required String status,
    double? amount,
    String? violatorId,
  }) async {
    // Determine which violator ID to use
    final idOfViolator = violatorId ?? _violatorSnapshot?.id;
    if (idOfViolator == null) {
      _showSnack('Error: Violator ID not found.', color: Colors.red);
      return;
    }

    _setLoading(true);
    try {
      // Step 1: Always create the incident record
      final newIncidentDoc = await _incidents.add({
        'violator_id': idOfViolator,
        'status': status,
        'incident_date': Timestamp.now(),
        'officer_name':
            FirebaseAuth.instance.currentUser?.email ?? 'Unknown Officer',
      });

      // Step 2: If it's a fine, also create the fine record
      if (status == 'Fine' && amount != null) {
        await _fines.add({
          'incident_id': newIncidentDoc.id,
          'amount': amount,
          'payment_status': 'Unpaid',
          'due_date': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 14)),
          ),
        });
        _smsService.sendFineNotificationSms(
          _violatorSnapshot!['mobile_number'],
          amount,
        );
      }

      _showSnack('New $status has been recorded.', color: Colors.green);
      // Step 3: Refresh the UI to show the new record
      await _fetchIncidents(idOfViolator);
    } catch (e) {
      _showSnack('Failed to record incident: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Add / Record ----------
  Future<void> _addNewViolator() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    try {
      final newViolator = await _violators.add({
        'full_name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
        'national_id_number': _searchController.text.trim(),
      });

      await _saveIncident(status: 'Warning', violatorId: newViolator.id);
      _showSnack('New violator added with a warning.', color: Colors.green);
      _clearSearch();
    } catch (e) {
      _showSnack('Failed to add violator: $e', color: Colors.red);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _recordNewIncident(String status) async {
    if (_violatorSnapshot == null) return;
    if (status == 'Fine') return _showIssueFineDialog();
    await _saveIncident(status: 'Warning');
  }

  void _showIssueFineDialog() {
    final fineController = TextEditingController();
    final fineFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Issue New Fine'),
        content: Form(
          key: fineFormKey,
          child: TextFormField(
            controller: fineController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Fine Amount (LKR)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Please enter an amount';
              if (double.tryParse(value!) == null)
                // ignore: curly_braces_in_flow_control_structures
                return 'Please enter a valid number';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!fineFormKey.currentState!.validate()) return;
              Navigator.of(context).pop();
              _saveIncident(
                status: 'Fine',
                amount: double.parse(fineController.text),
              );
            },
            child: const Text('Issue Fine'),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Incident')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by National ID (NIC)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchViolator,
                  ),
                  prefixIcon: (_violatorSnapshot != null || _noResult)
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_violatorSnapshot != null)
                ViolatorFoundView(
                  violatorSnapshot: _violatorSnapshot!,
                  incidentReports: _incidentReports,
                  onIssueWarning: () => _recordNewIncident('Warning'),
                  onIssueFine: () => _recordNewIncident('Fine'),
                  onTapIncident: (report) {
                    if (report.status == 'Fine' &&
                        report.paymentStatus == 'Unpaid') {
                      _showMarkAsPaidDialog(report);
                    }
                  },
                )
              else if (_noResult)
                AddViolatorForm(
                  formKey: _formKey,
                  nameController: _nameController,
                  addressController: _addressController,
                  mobileController: _mobileController,
                  nicNumber: _searchController.text.trim(),
                  onSave: _addNewViolator,
                )
              else
                const Center(child: Text('Enter an NIC and press search.')),
            ],
          ),
        ),
      ),
    );
  }
}
