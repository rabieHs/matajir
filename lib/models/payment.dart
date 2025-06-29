class Payment {
  final String id;
  final String userId;
  final String paymentIntentId;
  final String amount;
  final String currency;
  final String status;
  final String? description;
  final String? advertisementId;
  final String? storeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.advertisementId,
    this.storeId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['user_id'],
      paymentIntentId: json['payment_intent_id'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
      description: json['description'],
      advertisementId: json['advertisement_id'],
      storeId: json['store_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'payment_intent_id': paymentIntentId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      'advertisement_id': advertisementId,
      'store_id': storeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
