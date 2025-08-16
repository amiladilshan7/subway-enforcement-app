import {onDocumentCreated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import axios from "axios";
import * as crypto from "crypto";
import {log, error} from "firebase-functions/logger";

admin.initializeApp();
const db = admin.firestore();

// This is the new V2 syntax for a Firestore trigger
export const generatePayhereLink = onDocumentCreated("fines/{fineId}",
    async (event) => {
      const snap = event.data;
      if (!snap) {
        error("Event data is undefined, cannot process.");
        return;
      }

      try {
        const fineData = snap.data();
        const incidentId = fineData.incident_id;
        const fineAmount = fineData.amount;
        const orderId = snap.id;

        const incidentDoc = await db.collection("incidents").doc(incidentId).get();
        if (!incidentDoc.exists) {
          error("Incident not found for ID:", incidentId);
          return;
        }
        const violatorId = incidentDoc.data()?.violator_id;

        const violatorDoc = await db.collection("violators").doc(violatorId).get();
        if (!violatorDoc.exists) {
          error("Violator not found for ID:", violatorId);
          return;
        }
        const violatorData = violatorDoc.data();

        const merchantId = "YOUR_MERCHANT_ID"; // Replace with your ID
        const merchantSecret = "YOUR_MERCHANT_SECRET"; // Replace with your Secret

        const hashableString =
        `${merchantId}${orderId}${fineAmount.toFixed(2)}LKR${crypto
            .createHash("md5")
            .update(merchantSecret)
            .digest("hex")
            .toUpperCase()}`;

        const hash = crypto
            .createHash("md5")
            .update(hashableString)
            .digest("hex")
            .toUpperCase();

        const postData = {
          "sandbox": true,
          "merchant_id": merchantId,
          "return_url": "http://example.com/return",
          "cancel_url": "http://example.com/cancel",
          "notify_url": "http://example.com/notify",
          "order_id": orderId,
          "items": "Traffic Violation Fine",
          "amount": fineAmount,
          "currency": "LKR",
          "hash": hash,
          "first_name": violatorData?.full_name,
          "last_name": "",
          "email": "user@example.com",
          "phone": violatorData?.mobile_number,
          "address": violatorData?.address,
          "city": "Colombo",
          "country": "Sri Lanka",
        };

        const response = await axios.post(
            "https://sandbox.payhere.lk/pay/checkout",
            postData,
        );

        const paymentKey = response.data.data.hash;
        const paymentUrl = `https://sandbox.payhere.lk/pay/${paymentKey}`;

        await snap.ref.update({
          payment_url: paymentUrl,
          payment_hash: paymentKey,
        });

        log(`Successfully generated PayHere link for fine ${orderId}`);
      } catch (err) {
        error(`Failed to generate PayHere link for fine ${snap.id}`, err);
      }
    });
    