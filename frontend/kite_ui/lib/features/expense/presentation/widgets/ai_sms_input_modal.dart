import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/primary_button.dart';
import '../bloc/ai_parser_bloc.dart';
import '../bloc/ai_parser_event.dart';
import '../bloc/ai_parser_state.dart';

class AiSmsInputModal extends StatefulWidget {
  const AiSmsInputModal({super.key});

  @override
  State<AiSmsInputModal> createState() => _AiSmsInputModalState();
}

class _AiSmsInputModalState extends State<AiSmsInputModal> {
  final _smsController = TextEditingController();

  final List<String> _sampleSms = [
    'Spent INR 450.00 at Swiggy via HDFC Card ending 1024',
    'Paid Rs 1200.00 for Uber ride to airport via UPI',
    'Electricity bill payment of Rs 850.00 successful',
  ];

  @override
  void initState() {
    super.initState();
    context.read<AiParserBloc>().add(const ResetAiParserState());
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  void _onAnalyzePressed() {
    final text = _smsController.text.trim();
    context.read<AiParserBloc>().add(ParseSmsSubmitted(text));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<AiParserBloc, AiParserState>(
          listener: (context, state) {
            if (state is AiParserSuccess) {
              Navigator.pop(context, state.parsedExpense);
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'AI SMS Parser',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Paste bank SMS or transaction notification to auto-extract expense details.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // SMS Input Field
                CustomTextField(
                  controller: _smsController,
                  label: 'Bank SMS Text',
                  hintText: 'e.g. Spent INR 450.00 at Swiggy...',
                  prefixIcon: Icons.sms_outlined,
                  validator: (val) => null,
                ),
                const SizedBox(height: 12),

                // Sample SMS Quick Chips
                Text(
                  'Try sample SMS:',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _sampleSms.map((sample) {
                    return ActionChip(
                      label: Text(
                        sample.length > 28 ? '${sample.substring(0, 28)}...' : sample,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                      backgroundColor: AppColors.surfaceLight,
                      onPressed: () {
                        setState(() {
                          _smsController.text = sample;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                if (state is AiParserFailure) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],

                PrimaryButton(
                  text: 'Analyze & Auto-Fill ✨',
                  isLoading: state is AiParserLoading,
                  onPressed: _onAnalyzePressed,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
