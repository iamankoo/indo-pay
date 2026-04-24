enum PaymentEntryFlow {
  standard,
  qr,
  mobileUpi;

  static PaymentEntryFlow fromQuery(String? value) {
    return switch (value) {
      "qr" => PaymentEntryFlow.qr,
      "mobile-upi" => PaymentEntryFlow.mobileUpi,
      _ => PaymentEntryFlow.standard,
    };
  }

  String get queryValue => switch (this) {
        PaymentEntryFlow.standard => "standard",
        PaymentEntryFlow.qr => "qr",
        PaymentEntryFlow.mobileUpi => "mobile-upi",
      };

  String get title => switch (this) {
        PaymentEntryFlow.standard => "Payments",
        PaymentEntryFlow.qr => "QR Payment",
        PaymentEntryFlow.mobileUpi => "Pay Mobile / UPI",
      };

  String get initialCategory => switch (this) {
        PaymentEntryFlow.standard => "QR_PAYMENT",
        PaymentEntryFlow.qr => "QR_PAYMENT",
        PaymentEntryFlow.mobileUpi => "P2P_TRANSFER",
      };

  bool get showsCategoryChooser => this == PaymentEntryFlow.standard;

  bool get requiresRecipient => this == PaymentEntryFlow.mobileUpi;

  String get recipientLabel => "Mobile number or UPI ID";

  String submitLabel(int amount) => switch (this) {
        PaymentEntryFlow.mobileUpi => "Send INR $amount",
        _ => "Pay INR $amount",
      };
}
