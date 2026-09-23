import 'package:flutter/material.dart';

/// Represents a corporate voucher or employee benefit allowance.
class VoucherModel {
  final String id;
  final String title;
  final String category;
  final double balance;
  final double totalAmount;
  final String currency;
  final String code;
  final DateTime expiryDate;
  final String merchant;
  final IconData icon;
  final bool isExpiringSoon;

  const VoucherModel({
    required this.id,
    required this.title,
    required this.category,
    required this.balance,
    required this.totalAmount,
    this.currency = '\$',
    required this.code,
    required this.expiryDate,
    required this.merchant,
    required this.icon,
    this.isExpiringSoon = false,
  });

  /// Ratio of remaining balance to total allocation
  double get remainingRatio => totalAmount > 0 ? (balance / totalAmount).clamp(0.0, 1.0) : 0.0;

  /// Formatted remaining balance
  String get formattedBalance => '$currency${balance.toStringAsFixed(2)}';

  /// Formatted total budget
  String get formattedTotal => '$currency${totalAmount.toStringAsFixed(2)}';

  /// Mock sample vouchers for demonstration
  static List<VoucherModel> sampleVouchers = [
    VoucherModel(
      id: 'v1',
      title: 'Monthly Meal Stipend',
      category: 'Food & Dining',
      balance: 185.50,
      totalAmount: 250.00,
      code: 'CORP-EAT-9421',
      expiryDate: DateTime.now().add(const Duration(days: 8)),
      merchant: 'Uber Eats, DoorDash, Grubhub',
      icon: Icons.restaurant_rounded,
      isExpiringSoon: true,
    ),
    VoucherModel(
      id: 'v2',
      title: 'Wellness & Health Perk',
      category: 'Fitness',
      balance: 120.00,
      totalAmount: 120.00,
      code: 'WELL-GYM-5532',
      expiryDate: DateTime.now().add(const Duration(days: 28)),
      merchant: 'ClassPass, Equinox, Headspace',
      icon: Icons.fitness_center_rounded,
    ),
    VoucherModel(
      id: 'v3',
      title: 'Eco Commute Transit Pass',
      category: 'Transportation',
      balance: 45.00,
      totalAmount: 100.00,
      code: 'TRAN-MET-1180',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      merchant: 'City Metro, Lime, Zipcar',
      icon: Icons.directions_subway_rounded,
    ),
    VoucherModel(
      id: 'v4',
      title: 'Learning & Book Allowance',
      category: 'Education',
      balance: 200.00,
      totalAmount: 200.00,
      code: 'LEARN-EDU-7744',
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      merchant: 'O\'Reilly, Coursera, Bookstores',
      icon: Icons.auto_stories_rounded,
    ),
  ];
}
