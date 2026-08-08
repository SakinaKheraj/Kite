import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/sms_listener_bloc.dart';
import '../bloc/sms_listener_event.dart';
import '../bloc/sms_listener_state.dart';

class SmsSettingsTile extends StatelessWidget {
  const SmsSettingsTile({super.key});

  void _showPrivacyRationaleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: AppColors.secondary, size: 24),
            SizedBox(width: 8),
            Text(
              'Privacy-First SMS Listener',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Auto SMS Detection keeps your data 100% private:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              '• Only bank transaction SMS messages are processed.\n'
              '• Personal chat SMS & 10-digit mobile numbers are ignored locally.\n'
              '• OTPs, CVVs, and account digits are stripped on-device using Regex.\n'
              '• Every transaction requires your 1-tap confirmation before saving.',
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<SmsListenerBloc>().add(const ToggleSmsListener(true));
            },
            child: const Text('Enable & Grant Permission', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SmsListenerBloc, SmsListenerState>(
      builder: (context, state) {
        final isActive = state is SmsListenerActive || state is TransactionDetected || state is SmsListenerParsing;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? AppColors.secondary.withAlpha(100) : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.secondary : AppColors.textMuted).withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  color: isActive ? AppColors.secondary : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Auto Bank SMS Listener',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      isActive ? 'Active — Listening for bank transactions' : 'Disabled — Tap to enable auto-detect',
                      style: TextStyle(
                        fontSize: 11,
                        color: isActive ? AppColors.secondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                activeThumbColor: AppColors.secondary,
                onChanged: (val) {
                  if (val) {
                    _showPrivacyRationaleDialog(context);
                  } else {
                    context.read<SmsListenerBloc>().add(const ToggleSmsListener(false));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
