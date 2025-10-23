class TransactionModel {
  int? id;
  String title;
  double amount;
  String category;
  String date; // ISO string
  String type; // 'income' or 'expense'
  int userId;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'category': category,
    'date': date,
    'type': type,
    'userId': userId,
  };

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
    id: map['id'],
    title: map['title'],
    amount: (map['amount'] as num).toDouble(),
    category: map['category'],
    date: map['date'],
    type: map['type'],
    userId: map['userId'],
  );
}
