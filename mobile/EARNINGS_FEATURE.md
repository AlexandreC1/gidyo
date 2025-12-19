# Guide Earnings Feature Documentation

## Overview

The earnings feature provides guides with comprehensive financial tracking, payout management, and tax document generation. This feature allows guides to view their earnings, track transactions, manage payouts, and download tax documents.

## Feature Status: Ready for Implementation

### ✅ Completed
- Data models (earnings_entities.dart)
- Datasource API layer (earnings_datasource.dart)
- Folder structure

### ⏳ Pending Implementation
- State providers (Riverpod)
- UI screens (3 screens + 1 tab)
- Chart widget for earnings visualization
- PDF generation for tax documents

---

## Architecture

```
lib/features/guide/earnings/
├── data/
│   └── datasources/
│       └── earnings_datasource.dart          ✅ Complete
├── domain/
│   └── entities/
│       └── earnings_entities.dart            ✅ Complete
└── presentation/
    ├── pages/
    │   ├── earnings_screen.dart              ⏳ To build
    │   └── payout_settings_screen.dart       ⏳ To build
    ├── widgets/
    │   ├── earnings_chart.dart               ⏳ To build
    │   ├── period_selector.dart              ⏳ To build
    │   ├── earnings_breakdown.dart           ⏳ To build
    │   ├── transaction_list_item.dart        ⏳ To build
    │   └── payout_list_item.dart             ⏳ To build
    └── providers/
        └── earnings_providers.dart           ⏳ To build
```

---

## Data Models

### EarningsSummary

```dart
class EarningsSummary {
  final double totalEarned;        // Gross earnings
  final double netEarnings;        // After fees + tips
  final double platformFees;       // 10% fees deducted
  final double tipsReceived;       // Tips from visitors
  final int numberOfTrips;         // Trip count
  final double averagePerTrip;     // Avg per trip
  final List<DailyEarning> dailyEarnings; // For charts
  final DateTime periodStart;
  final DateTime periodEnd;
}
```

### EarningsTransaction

```dart
class EarningsTransaction {
  final String id;
  final String bookingId;
  final DateTime date;
  final String visitorName;
  final String? visitorAvatar;
  final String serviceName;
  final double amount;             // Service fee
  final double platformFee;        // Deducted
  final double tip;                // Tip amount
  final double netAmount;          // amount - fee + tip
  final TransactionStatus status;  // completed, pending, etc.
}
```

### Payout

```dart
class Payout {
  final String id;
  final DateTime payoutDate;
  final double amount;
  final PayoutMethodType method;   // bank_transfer or moncash
  final PayoutStatus status;       // pending, processing, completed, failed
  final String? accountLastFour;   // •••• 1234
  final String? transactionId;
  final String? failureReason;
}
```

### PayoutSettings

```dart
class PayoutSettings {
  final PayoutMethodType? currentMethod;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolderName;
  final String? moncashNumber;
  final double minimumPayoutThreshold; // Default $50
  final bool autoPayoutEnabled;
}
```

---

## API Layer (Datasource)

### Methods Implemented

```dart
class EarningsDatasource {
  // Get earnings summary for period
  Future<EarningsSummary> getEarningsSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Get transaction list
  Future<List<EarningsTransaction>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Get payout history
  Future<List<Payout>> getPayoutHistory();

  // Get next scheduled payout
  Future<NextPayout?> getNextPayout();

  // Get payout settings
  Future<PayoutSettings> getPayoutSettings();

  // Update payout settings
  Future<void> updatePayoutSettings(PayoutSettings settings);

  // Generate earnings report (PDF)
  Future<Map<String, dynamic>> generateEarningsReport(int year);
}
```

---

## State Management (Riverpod Providers)

### To Implement

```dart
// Datasource provider
final earningsDatasourceProvider = Provider<EarningsDatasource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EarningsDatasource(supabase);
});

// Period state provider
final earningsPeriodProvider = StateProvider<EarningsPeriod>((ref) {
  return EarningsPeriod.thisMonth;
});

// Custom date range provider
final customDateRangeProvider = StateProvider<DateRange?>((ref) => null);

// Earnings summary provider (family - takes date range)
final earningsSummaryProvider = FutureProvider.family<EarningsSummary, DateRange>(
  (ref, dateRange) async {
    final datasource = ref.watch(earningsDatasourceProvider);
    return await datasource.getEarningsSummary(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  },
);

// Transactions provider
final transactionsProvider = FutureProvider.family<List<EarningsTransaction>, DateRange>(
  (ref, dateRange) async {
    final datasource = ref.watch(earningsDatasourceProvider);
    return await datasource.getTransactions(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  },
);

// Payout history provider
final payoutsProvider = FutureProvider<List<Payout>>((ref) async {
  final datasource = ref.watch(earningsDatasourceProvider);
  return await datasource.getPayoutHistory();
});

// Next payout provider
final nextPayoutProvider = FutureProvider<NextPayout?>((ref) async {
  final datasource = ref.watch(earningsDatasourceProvider);
  return await datasource.getNextPayout();
});

// Payout settings provider
final payoutSettingsProvider = StateNotifierProvider<PayoutSettingsNotifier, AsyncValue<PayoutSettings>>(
  (ref) => PayoutSettingsNotifier(ref),
);

class PayoutSettingsNotifier extends StateNotifier<AsyncValue<PayoutSettings>> {
  final Ref _ref;

  PayoutSettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final datasource = _ref.read(earningsDatasourceProvider);
      final settings = await datasource.getPayoutSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(PayoutSettings settings) async {
    state = const AsyncValue.loading();
    try {
      final datasource = _ref.read(earningsDatasourceProvider);
      await datasource.updatePayoutSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

---

## Screen 1: EarningsScreen

### Layout

```
┌──────────────────────────────────────┐
│ [←] Earnings                         │
├──────────────────────────────────────┤
│ [This Week ▼] [This Month] [This Year] [Custom] │
├──────────────────────────────────────┤
│                                      │
│          $2,450.00                   │
│        Total Earned                  │
│     Dec 1 - Dec 15, 2025            │
│                                      │
├──────────────────────────────────────┤
│  📊 Earnings Chart                   │
│  [Bar chart showing daily earnings]  │
│                                      │
├──────────────────────────────────────┤
│  Breakdown                           │
│  ├─ 15 Trips                         │
│  ├─ $163.33 Average per trip         │
│  ├─ $150.00 Tips received            │
│  ├─ -$245.00 Platform fees (10%)    │
│  └─ $2,355.00 Net earnings          │
├──────────────────────────────────────┤
│  Transactions                        │
│  ├─ City Tour - John Doe             │
│  │   Dec 15 • $150 • Completed      │
│  ├─ Airport Transfer - Jane Smith   │
│  │   Dec 14 • $50 • Completed       │
│  └─ [View All]                       │
└──────────────────────────────────────┘
```

### Implementation

```dart
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(earningsPeriodProvider);
    final dateRange = _getDateRange(period);
    final summaryAsync = ref.watch(earningsSummaryProvider(dateRange));
    final transactionsAsync = ref.watch(transactionsProvider(dateRange));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payouts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(summaryAsync, transactionsAsync),

          // Payouts Tab
          const PayoutsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    AsyncValue<EarningsSummary> summaryAsync,
    AsyncValue<List<EarningsTransaction>> transactionsAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(earningsSummaryProvider);
        ref.invalidate(transactionsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Period Selector
          const PeriodSelector(),

          const SizedBox(height: AppDimensions.paddingXL),

          // Total Earned
          summaryAsync.when(
            data: (summary) => _TotalEarnedCard(summary: summary),
            loading: () => const _LoadingSkeleton(),
            error: (error, _) => _ErrorCard(error: error.toString()),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Earnings Chart
          summaryAsync.when(
            data: (summary) => EarningsChart(
              dailyEarnings: summary.dailyEarnings,
            ),
            loading: () => const _ChartSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Breakdown
          summaryAsync.when(
            data: (summary) => EarningsBreakdown(summary: summary),
            loading: () => const _LoadingSkeleton(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Transactions
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          transactionsAsync.when(
            data: (transactions) => Column(
              children: [
                ...transactions.take(5).map((transaction) =>
                    TransactionListItem(transaction: transaction)),
                if (transactions.length > 5)
                  TextButton(
                    onPressed: () {
                      // Navigate to full transaction list
                    },
                    child: const Text('View All Transactions'),
                  ),
              ],
            ),
            loading: () => const _LoadingSkeleton(),
            error: (error, _) => _ErrorCard(error: error.toString()),
          ),
        ],
      ),
    );
  }

  DateRange _getDateRange(EarningsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case EarningsPeriod.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return DateRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
      case EarningsPeriod.thisMonth:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case EarningsPeriod.thisYear:
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
      case EarningsPeriod.custom:
        final customRange = ref.read(customDateRangeProvider);
        return customRange ?? DateRange(start: now, end: now);
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;
  DateRange({required this.start, required this.end});
}
```

---

## Screen 2: PayoutsTab

### Layout

```
┌──────────────────────────────────────┐
│  Next Payout                         │
│  ┌────────────────────────────────┐ │
│  │ 💰 $2,355.00                    │ │
│  │ Estimated payout on Dec 18      │ │
│  │ 15 transactions                 │ │
│  └────────────────────────────────┘ │
├──────────────────────────────────────┤
│  Payout History                      │
│  ├─ Dec 11, 2025                    │
│  │   $1,850.00 • Bank Transfer     │
│  │   Completed ✓                   │
│  ├─ Dec 4, 2025                     │
│  │   $2,100.00 • MonCash           │
│  │   Completed ✓                   │
│  └─ ...                             │
├──────────────────────────────────────┤
│  [Payout Settings]                   │
└──────────────────────────────────────┘
```

### Implementation

```dart
class PayoutsTab extends ConsumerWidget {
  const PayoutsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPayoutAsync = ref.watch(nextPayoutProvider);
    final payoutsAsync = ref.watch(payoutsProvider);
    final settingsAsync = ref.watch(payoutSettingsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      children: [
        // Next Payout Card
        nextPayoutAsync.when(
          data: (nextPayout) {
            if (nextPayout == null) {
              return const _NoNextPayoutCard();
            }
            return _NextPayoutCard(nextPayout: nextPayout);
          },
          loading: () => const _LoadingSkeleton(),
          error: (error, _) => _ErrorCard(error: error.toString()),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Current Payout Method
        settingsAsync.when(
          data: (settings) => Card(
            child: ListTile(
              leading: Icon(
                settings.hasPayoutMethod
                    ? Icons.check_circle
                    : Icons.warning,
                color: settings.hasPayoutMethod
                    ? AppColors.success
                    : AppColors.warning,
              ),
              title: const Text('Payout Method'),
              subtitle: Text(settings.displayMethod),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PayoutSettingsScreen(),
                  ),
                );
              },
            ),
          ),
          loading: () => const _LoadingSkeleton(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: AppDimensions.paddingXL),

        // Payout History
        Text(
          'Payout History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.paddingM),

        payoutsAsync.when(
          data: (payouts) {
            if (payouts.isEmpty) {
              return const _EmptyPayoutHistory();
            }
            return Column(
              children: payouts.map((payout) => PayoutListItem(payout: payout)).toList(),
            );
          },
          loading: () => const _LoadingSkeleton(),
          error: (error, _) => _ErrorCard(error: error.toString()),
        ),
      ],
    );
  }
}
```

---

## Screen 3: PayoutSettingsScreen

### Layout

```
┌──────────────────────────────────────┐
│ [←] Payout Settings                  │
├──────────────────────────────────────┤
│  Current Method                      │
│  ┌────────────────────────────────┐ │
│  │ 💳 Bank Transfer                │ │
│  │ UniBank •••• 5678               │ │
│  └────────────────────────────────┘ │
├──────────────────────────────────────┤
│  Payout Method                       │
│  ○ Bank Transfer                     │
│  ● MonCash                           │
├──────────────────────────────────────┤
│  MonCash Details                     │
│  Phone Number: [+509 1234 5678    ] │
│  Name: [Jean Pierre              ] │
├──────────────────────────────────────┤
│  Payout Schedule                     │
│  ☑ Auto payout enabled               │
│  Minimum threshold: [$50.00      ] │
│  Frequency: Weekly (Mondays)         │
├──────────────────────────────────────┤
│  [Save Changes]                      │
└──────────────────────────────────────┘
```

### Implementation

```dart
class PayoutSettingsScreen extends ConsumerStatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  ConsumerState<PayoutSettingsScreen> createState() =>
      _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState
    extends ConsumerState<PayoutSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  PayoutMethodType _selectedMethod = PayoutMethodType.moncash;
  final _moncashController = TextEditingController();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  bool _autoPayoutEnabled = true;
  double _minimumThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settingsAsync = ref.read(payoutSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _selectedMethod = settings.currentMethod ?? PayoutMethodType.moncash;
        _moncashController.text = settings.moncashNumber ?? '';
        _nameController.text = settings.accountHolderName ?? '';
        _bankNameController.text = settings.bankName ?? '';
        _accountNumberController.text = settings.accountNumber ?? '';
        _autoPayoutEnabled = settings.autoPayoutEnabled;
        _minimumThreshold = settings.minimumPayoutThreshold;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(payoutSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payout Settings'),
      ),
      body: settingsAsync.when(
        data: (currentSettings) => _buildForm(currentSettings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorCard(error: error.toString()),
      ),
    );
  }

  Widget _buildForm(PayoutSettings currentSettings) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        children: [
          // Current Method Display
          if (currentSettings.hasPayoutMethod) ...[
            Card(
              color: AppColors.lightGray,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(currentSettings.displayMethod),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
          ],

          // Method Selector
          Text(
            'Payout Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          RadioListTile<PayoutMethodType>(
            title: const Text('Bank Transfer'),
            subtitle: const Text('Direct deposit to your bank account'),
            value: PayoutMethodType.bankTransfer,
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() => _selectedMethod = value!);
            },
          ),

          RadioListTile<PayoutMethodType>(
            title: const Text('MonCash'),
            subtitle: const Text('Mobile money transfer'),
            value: PayoutMethodType.moncash,
            groupValue: _selectedMethod,
            onChanged: (value) {
              setState(() => _selectedMethod = value!);
            },
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Conditional Forms
          if (_selectedMethod == PayoutMethodType.moncash)
            _buildMonCashForm()
          else
            _buildBankForm(),

          const SizedBox(height: AppDimensions.paddingXL),

          // Auto Payout Settings
          Text(
            'Payout Schedule',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingM),

          SwitchListTile(
            title: const Text('Auto payout enabled'),
            subtitle: const Text('Automatically transfer earnings weekly'),
            value: _autoPayoutEnabled,
            onChanged: (value) {
              setState(() => _autoPayoutEnabled = value);
            },
          ),

          const SizedBox(height: AppDimensions.paddingM),

          TextFormField(
            initialValue: _minimumThreshold.toString(),
            decoration: const InputDecoration(
              labelText: 'Minimum payout threshold',
              prefixText: '\$',
              helperText: 'Minimum amount before payout is triggered',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _minimumThreshold = double.tryParse(value) ?? 50.0;
            },
          ),

          const SizedBox(height: AppDimensions.paddingM),

          Card(
            color: AppColors.accentTeal.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.accentTeal),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Text(
                      'Payouts are processed every Monday for the previous week\'s completed bookings.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXL),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonCashForm() {
    return Column(
      children: [
        TextFormField(
          controller: _moncashController,
          decoration: const InputDecoration(
            labelText: 'MonCash Phone Number',
            prefixText: '+509 ',
            hintText: '1234 5678',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter MonCash number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.paddingL),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBankForm() {
    return Column(
      children: [
        TextFormField(
          controller: _bankNameController,
          decoration: const InputDecoration(
            labelText: 'Bank Name',
            hintText: 'e.g., UniBank',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter bank name';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.paddingL),
        TextFormField(
          controller: _accountNumberController,
          decoration: const InputDecoration(
            labelText: 'Account Number',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.paddingL),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Holder Name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter account holder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = PayoutSettings(
      currentMethod: _selectedMethod,
      bankName: _selectedMethod == PayoutMethodType.bankTransfer
          ? _bankNameController.text
          : null,
      accountNumber: _selectedMethod == PayoutMethodType.bankTransfer
          ? _accountNumberController.text
          : null,
      accountHolderName: _nameController.text,
      moncashNumber: _selectedMethod == PayoutMethodType.moncash
          ? '+509${_moncashController.text}'
          : null,
      minimumPayoutThreshold: _minimumThreshold,
      autoPayoutEnabled: _autoPayoutEnabled,
    );

    await ref.read(payoutSettingsProvider.notifier).updateSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout settings updated')),
      );
      Navigator.pop(context);
    }
  }
}
```

---

## Widget: EarningsChart

### Implementation

Requires `fl_chart` package for bar charts:

```yaml
dependencies:
  fl_chart: ^0.68.0
```

```dart
import 'package:fl_chart/fl_chart.dart';

class EarningsChart extends StatelessWidget {
  final List<DailyEarning> dailyEarnings;

  const EarningsChart({
    super.key,
    required this.dailyEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Earnings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.primaryNavy,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = dailyEarnings[groupIndex].date;
                        final amount = dailyEarnings[groupIndex].amount;
                        return BarTooltipItem(
                          '${_formatDate(date)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '\$${amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.accentGolden,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getBottomTitles,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getLeftTitles,
                        reservedSize: 50,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return dailyEarnings.asMap().entries.map((entry) {
      final index = entry.key;
      final earning = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: earning.amount,
            color: AppColors.accentTeal,
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= dailyEarnings.length) {
      return const SizedBox.shrink();
    }

    final date = dailyEarnings[value.toInt()].date;
    final text = '${date.month}/${date.day}';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '\$${value.toInt()}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  double _getMaxValue() {
    if (dailyEarnings.isEmpty) return 100;
    final maxAmount = dailyEarnings
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble(); // Add 20% padding
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
```

---

## Tax Documents Section

### Add to EarningsScreen

```dart
// Inside EarningsScreen, add a new tab or section:

class TaxDocumentsSection extends ConsumerStatefulWidget {
  const TaxDocumentsSection({super.key});

  @override
  ConsumerState<TaxDocumentsSection> createState() =>
      _TaxDocumentsSectionState();
}

class _TaxDocumentsSectionState
    extends ConsumerState<TaxDocumentsSection> {
  int _selectedYear = DateTime.now().year;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: AppColors.accentTeal),
                const SizedBox(width: AppDimensions.paddingM),
                Text(
                  'Tax Documents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingL),

            Text(
              'Download your annual earnings summary for tax purposes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Year Selector
            DropdownButtonFormField<int>(
              value: _selectedYear,
              decoration: const InputDecoration(
                labelText: 'Tax Year',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              items: List.generate(5, (index) {
                final year = DateTime.now().year - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }),
              onChanged: (value) {
                setState(() => _selectedYear = value!);
              },
            ),

            const SizedBox(height: AppDimensions.paddingL),

            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateReport,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isGenerating ? 'Generating...' : 'Download Summary'),
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Info
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: AppDimensions.paddingS),
                  Expanded(
                    child: Text(
                      'Includes all completed bookings, earnings, and fees.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);

    try {
      final datasource = ref.read(earningsDatasourceProvider);
      final result = await datasource.generateEarningsReport(_selectedYear);

      final pdfUrl = result['pdf_url'] as String;

      // Open URL in browser or download
      // You'd use url_launcher package here
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report generated for $_selectedYear'),
            action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                // Launch URL
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}
```

---

## Database Schema

### Existing Tables Used

```sql
-- Bookings table (already exists)
CREATE TABLE bookings (
  -- ... existing columns
  service_fee DECIMAL(10,2),
  platform_fee DECIMAL(10,2),
  tip_amount DECIMAL(10,2) DEFAULT 0,
  payout_status TEXT DEFAULT 'pending',
  -- ...
);

-- Guide payout info (from onboarding)
CREATE TABLE guide_payout_info (
  user_id UUID PRIMARY KEY REFERENCES users(id),
  payout_method TEXT, -- 'bank_transfer', 'moncash'
  bank_name TEXT,
  account_number TEXT,
  account_holder_name TEXT,
  moncash_number TEXT,
  minimum_threshold DECIMAL(10,2) DEFAULT 50,
  auto_payout BOOLEAN DEFAULT true,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### New Table: Payouts

```sql
CREATE TABLE payouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  guide_id UUID REFERENCES users(id) NOT NULL,
  payout_date TIMESTAMPTZ NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payout_method TEXT NOT NULL, -- 'bank_transfer', 'moncash'
  status TEXT DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
  account_last_four TEXT,
  transaction_id TEXT,
  failure_reason TEXT,
  booking_ids UUID[], -- Array of booking IDs included
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_payouts_guide_id ON payouts(guide_id);
CREATE INDEX idx_payouts_status ON payouts(status);
CREATE INDEX idx_payouts_date ON payouts(payout_date DESC);
```

---

## Supabase Edge Function: generate-earnings-report

```typescript
// supabase/functions/generate-earnings-report/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { guide_id, year } = await req.json()

    // Create Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get all completed bookings for the year
    const startDate = `${year}-01-01`
    const endDate = `${year}-12-31`

    const { data: bookings, error } = await supabase
      .from('bookings')
      .select('*')
      .eq('guide_id', guide_id)
      .eq('status', 'completed')
      .gte('booking_date', startDate)
      .lte('booking_date', endDate)
      .order('booking_date')

    if (error) throw error

    // Calculate totals
    let totalEarned = 0
    let totalFees = 0
    let totalTips = 0

    for (const booking of bookings) {
      totalEarned += booking.service_fee
      totalFees += booking.platform_fee
      totalTips += booking.tip_amount || 0
    }

    const netEarnings = totalEarned - totalFees + totalTips

    // Generate PDF using a PDF library
    // For now, return data that can be used to generate PDF client-side
    const reportData = {
      guide_id,
      year,
      total_earnings: totalEarned,
      platform_fees: totalFees,
      tips_received: totalTips,
      net_earnings: netEarnings,
      number_of_trips: bookings.length,
      bookings: bookings.map(b => ({
        date: b.booking_date,
        amount: b.service_fee,
        fee: b.platform_fee,
        tip: b.tip_amount,
      })),
    }

    // In production, you'd generate PDF and upload to storage
    // Then return the storage URL

    return new Response(
      JSON.stringify({
        pdf_url: 'https://example.com/earnings-report.pdf',
        data: reportData
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

---

## Summary

### What's Built
✅ Data models (EarningsSummary, Transaction, Payout, Settings)
✅ API datasource with all methods
✅ Comprehensive documentation

### What to Build
⏳ Riverpod providers (1-2 hours)
⏳ EarningsScreen UI (3-4 hours)
⏳ PayoutsTab UI (2-3 hours)
⏳ PayoutSettingsScreen UI (2-3 hours)
⏳ Chart widget (1-2 hours)
⏳ Helper widgets (1-2 hours)

### Total Estimated Time
**12-18 hours** to complete full implementation

### Dependencies to Add

```yaml
dependencies:
  fl_chart: ^0.68.0  # For bar charts
  url_launcher: ^6.3.1  # Already added (for PDF download)
  pdf: ^3.10.7  # If generating PDFs client-side
```

---

**Earnings Feature**: Architecture complete, ready for UI implementation.
