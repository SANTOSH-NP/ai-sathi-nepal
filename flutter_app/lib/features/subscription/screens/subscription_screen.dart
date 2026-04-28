import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearly = false;
  bool _isProcessing = false;

  Future<void> _subscribe(String method) async {
    setState(() => _isProcessing = true);

    try {
      final planType = _isYearly ? 'premium_yearly' : 'premium_monthly';
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.paymentInit, data: {
        'planType': planType,
        'method': method,
      });

      if (response.data['success']) {
        final data = response.data['data'];

        switch (method) {
          case 'khalti':
            // Open Khalti payment URL
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Redirecting to Khalti...')),
            );
            break;
          case 'esewa':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Redirecting to eSewa...')),
            );
            break;
          case 'stripe':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening Stripe checkout...')),
            );
            break;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Premium Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Premium banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.premiumGradientStart, AppColors.premiumGradientEnd],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'AI Sathi Premium',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock the full power of AI',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features list
            _featureRow(Icons.all_inclusive, 'Unlimited AI usage'),
            _featureRow(Icons.download, 'Unlimited CV downloads'),
            _featureRow(Icons.block, 'No advertisements'),
            _featureRow(Icons.speed, 'Faster AI responses'),
            _featureRow(Icons.support, 'Priority support'),
            _featureRow(Icons.picture_as_pdf, 'Unlimited Image to PDF'),
            const SizedBox(height: 24),

            // Plan toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Monthly'),
                Switch(
                  value: _isYearly,
                  onChanged: (v) => setState(() => _isYearly = v),
                  activeColor: AppColors.primary,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Yearly'),
                    Text(
                      'Save 30%!',
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price display
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      _isYearly ? 'Yearly Plan' : 'Monthly Plan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textPrimary),
                        children: [
                          TextSpan(
                            text: _isYearly
                                ? 'NPR ${AppConstants.premiumYearlyPriceNPR}'
                                : 'NPR ${AppConstants.premiumMonthlyPriceNPR}',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: _isYearly ? '/year' : '/month',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _isYearly
                          ? '(\$${AppConstants.premiumYearlyPriceUSD}/year)'
                          : '(\$${AppConstants.premiumMonthlyPriceUSD}/month)',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment methods
            const Text(
              'Choose Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Nepal payments
            _paymentButton(
              'Khalti',
              Icons.account_balance_wallet,
              Colors.purple,
              () => _subscribe('khalti'),
            ),
            _paymentButton(
              'eSewa',
              Icons.account_balance_wallet,
              Colors.green,
              () => _subscribe('esewa'),
            ),
            _paymentButton(
              'Stripe (International)',
              Icons.credit_card,
              AppColors.primary,
              () => _subscribe('stripe'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  Widget _paymentButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
