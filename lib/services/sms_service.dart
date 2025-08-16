import 'package:flutter/foundation.dart';

class SmsService {
  // MOCK function to "send" an SMS when a fine is issued
  void sendFineNotificationSms(String mobileNumber, double amount) {
    final message =
        'You have been issued a fine of ${amount.toStringAsFixed(2)} LKR for a traffic violation. '
        'Please settle the payment within 14 days.';

    // The kDebugMode check ensures this only prints in development, not in a real app.
    if (kDebugMode) {
      print('--- MOCK SMS SENT to $mobileNumber ---');
      print(message);
      print('------------------------------------');
    }
  }

  // MOCK function to "send" a confirmation SMS when a fine is paid
  void sendPaymentConfirmationSms(String mobileNumber, double amount) {
    final message =
        'Thank you. We have received your payment of ${amount.toStringAsFixed(2)} LKR. '
        'Your fine is now settled.';

    if (kDebugMode) {
      print('--- MOCK SMS SENT to $mobileNumber ---');
      print(message);
      print('------------------------------------');
    }
  }
}
