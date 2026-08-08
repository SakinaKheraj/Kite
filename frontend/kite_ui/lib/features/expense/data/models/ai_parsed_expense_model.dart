import 'package:equatable/equatable.dart';

class AiParsedExpenseModel extends Equatable {
  final double amount;
  final String category;
  final String description;
  final double confidence;

  const AiParsedExpenseModel({
    required this.amount,
    required this.category,
    required this.description,
    this.confidence = 0.95,
  });

  factory AiParsedExpenseModel.fromJson(Map<String, dynamic> json) {
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      } else {
        parsedAmount = double.tryParse(json['amount'].toString()) ?? 0.0;
      }
    }

    double parsedConfidence = 0.95;
    if (json['confidence'] != null) {
      if (json['confidence'] is num) {
        parsedConfidence = (json['confidence'] as num).toDouble();
      } else {
        parsedConfidence = double.tryParse(json['confidence'].toString()) ?? 0.95;
      }
    }

    return AiParsedExpenseModel(
      amount: parsedAmount,
      category: json['category'] != null ? json['category'].toString() : 'Other',
      description: json['description'] != null ? json['description'].toString() : 'SMS Expense',
      confidence: parsedConfidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [amount, category, description, confidence];
}
