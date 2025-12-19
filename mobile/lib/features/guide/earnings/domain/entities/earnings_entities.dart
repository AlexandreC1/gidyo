import 'package:equatable/equatable.dart';

enum EarningsPeriod {
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

enum TransactionStatus {
  completed,
  pending,
  cancelled,
  refunded,
}

enum PayoutStatus {
  pending,
  processing,
  completed,
  failed,
}

enum PayoutMethodType {
  bankTransfer,
  moncash,
}

/// Earnings summary for a specific period
class EarningsSummary extends Equatable {
  final double totalEarned;
  final double netEarnings;
  final double platformFees;
  final double tipsReceived;
  final int numberOfTrips;
  final double averagePerTrip;
  final List<DailyEarning> dailyEarnings;
  final DateTime periodStart;
  final DateTime periodEnd;

  const EarningsSummary({
    required this.totalEarned,
    required this.netEarnings,
    required this.platformFees,
    required this.tipsReceived,
    required this.numberOfTrips,
    required this.averagePerTrip,
    required this.dailyEarnings,
    required this.periodStart,
    required this.periodEnd,
  });

  double get platformFeePercentage =>
      totalEarned > 0 ? (platformFees / totalEarned) * 100 : 0;

  @override
  List<Object?> get props => [
        totalEarned,
        netEarnings,
        platformFees,
        tipsReceived,
        numberOfTrips,
        averagePerTrip,
        dailyEarnings,
        periodStart,
        periodEnd,
      ];
}

/// Daily earnings data point for charts
class DailyEarning extends Equatable {
  final DateTime date;
  final double amount;
  final int tripCount;

  const DailyEarning({
    required this.date,
    required this.amount,
    required this.tripCount,
  });

  @override
  List<Object?> get props => [date, amount, tripCount];
}

/// Individual transaction/booking
class EarningsTransaction extends Equatable {
  final String id;
  final String bookingId;
  final DateTime date;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceName;
  final double amount;
  final double platformFee;
  final double tip;
  final double netAmount;
  final TransactionStatus status;

  const EarningsTransaction({
    required this.id,
    required this.bookingId,
    required this.date,
    required this.visitorName,
    this.visitorAvatar,
    required this.serviceName,
    required this.amount,
    required this.platformFee,
    required this.tip,
    required this.netAmount,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        date,
        visitorName,
        visitorAvatar,
        serviceName,
        amount,
        platformFee,
        tip,
        netAmount,
        status,
      ];
}

/// Payout information
class Payout extends Equatable {
  final String id;
  final DateTime payoutDate;
  final double amount;
  final PayoutMethodType method;
  final PayoutStatus status;
  final String? accountLastFour; // Last 4 digits of account/card
  final String? transactionId;
  final String? failureReason;

  const Payout({
    required this.id,
    required this.payoutDate,
    required this.amount,
    required this.method,
    required this.status,
    this.accountLastFour,
    this.transactionId,
    this.failureReason,
  });

  String get methodDisplay {
    switch (method) {
      case PayoutMethodType.bankTransfer:
        return 'Bank Transfer';
      case PayoutMethodType.moncash:
        return 'MonCash';
    }
  }

  String get statusDisplay {
    switch (status) {
      case PayoutStatus.pending:
        return 'Pending';
      case PayoutStatus.processing:
        return 'Processing';
      case PayoutStatus.completed:
        return 'Completed';
      case PayoutStatus.failed:
        return 'Failed';
    }
  }

  @override
  List<Object?> get props => [
        id,
        payoutDate,
        amount,
        method,
        status,
        accountLastFour,
        transactionId,
        failureReason,
      ];
}

/// Next scheduled payout
class NextPayout extends Equatable {
  final DateTime payoutDate;
  final double estimatedAmount;
  final int transactionCount;

  const NextPayout({
    required this.payoutDate,
    required this.estimatedAmount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [payoutDate, estimatedAmount, transactionCount];
}

/// Payout settings
class PayoutSettings extends Equatable {
  final PayoutMethodType? currentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? moncashNumber;
  final double minimumPayoutThreshold;
  final bool autoPayoutEnabled;

  const PayoutSettings({
    this.currentMethod,
    this.bankName,
    this.accountNumber,
    this.accountHolderName,
    this.moncashNumber,
    this.minimumPayoutThreshold = 50.0, // Default $50
    this.autoPayoutEnabled = true,
  });

  bool get hasPayoutMethod => currentMethod != null;

  String get displayMethod {
    if (currentMethod == null) return 'Not set';
    switch (currentMethod!) {
      case PayoutMethodType.bankTransfer:
        return 'Bank: ${bankName ?? 'Unknown'} •••• ${accountNumber?.substring(accountNumber!.length - 4) ?? ''}';
      case PayoutMethodType.moncash:
        return 'MonCash: ${moncashNumber ?? 'Unknown'}';
    }
  }

  PayoutSettings copyWith({
    PayoutMethodType? currentMethod,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    String? moncashNumber,
    double? minimumPayoutThreshold,
    bool? autoPayoutEnabled,
  }) {
    return PayoutSettings(
      currentMethod: currentMethod ?? this.currentMethod,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      moncashNumber: moncashNumber ?? this.moncashNumber,
      minimumPayoutThreshold:
          minimumPayoutThreshold ?? this.minimumPayoutThreshold,
      autoPayoutEnabled: autoPayoutEnabled ?? this.autoPayoutEnabled,
    );
  }

  @override
  List<Object?> get props => [
        currentMethod,
        bankName,
        accountNumber,
        accountHolderName,
        moncashNumber,
        minimumPayoutThreshold,
        autoPayoutEnabled,
      ];
}
