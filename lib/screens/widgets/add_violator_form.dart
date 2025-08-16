import 'package:flutter/material.dart';

class AddViolatorForm extends StatelessWidget {
  // We need to receive the controllers and keys from the parent screen
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController mobileController;
  final String nicNumber;
  final VoidCallback onSave;

  const AddViolatorForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.addressController,
    required this.mobileController,
    required this.nicNumber,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Violator Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Text('Please add their details below.'),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'NIC: $nicNumber',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a mobile number' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onSave, // Call the function passed from the parent
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Save & Issue First Warning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
