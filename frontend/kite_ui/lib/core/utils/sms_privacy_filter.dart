class SmsPrivacyFilter {
  SmsPrivacyFilter._();

  // Known bank sender code prefixes (e.g., AD-HDFCBK, AX-ICICIB, AMEX)
  static final RegExp _bankSenderRegex = RegExp(
    r'(HDFCBK|ICICIB|AXISBK|SBIINB|KOTAK|PNBSMS|AMEX|YESBNK|IDFCFB|INDUSI|CANBNK|BOIIND|UNIONB|PAYTM|SLICE|BOB|CENTBK|IOB)',
    caseSensitive: false,
  );

  // General financial transaction keywords
  static final RegExp _transactionKeywordRegex = RegExp(
    r'(debit|debited|credit|credited|spent|spent at|paid|paid to|vpa|upi|inr|rs\.?|card ending|account ending|a/c|acct)',
    caseSensitive: false,
  );

  // 10-digit personal mobile number pattern (e.g., 9876543210, +919876543210)
  static final RegExp _personalPhoneRegex = RegExp(
    r'^\+?(?:91)?[6-9]\d{9}$',
  );

  // OTP / CVV / Password / Account sensitive regex patterns for local sanitization
  static final RegExp _otpRegex = RegExp(
    r'(?:otp|one time password|verification code|secret code|auth code|cvv|password|pin|valid for)\s*(?:is|:|-)?\s*(\d{4,8})',
    caseSensitive: false,
  );

  static final RegExp _fullAccountRegex = RegExp(
    r'(?:account|a/c|acct|card)\s*(?:no\.?|number)?\s*(\d{8,16})',
    caseSensitive: false,
  );

  /// Validates if an SMS is an authentic financial transaction message
  static bool isFinancialSms(String sender, String body) {
    if (body.trim().isEmpty) return false;

    final senderClean = sender.trim().replaceAll(RegExp(r'[^a-zA-Z0-9+]'), '');

    // Rule 1: Ignore 10-digit personal phone numbers completely
    if (_personalPhoneRegex.hasMatch(senderClean)) {
      return false;
    }

    // Rule 2: Must match bank sender shortcodes OR contain financial keywords
    final isBankSender = _bankSenderRegex.hasMatch(senderClean);
    final hasKeywords = _transactionKeywordRegex.hasMatch(body);

    return isBankSender || hasKeywords;
  }

  /// Sanitizes raw SMS body on-device: strips OTPs, CVVs, passwords, and full account digits
  static String sanitizeSmsBody(String rawBody) {
    if (rawBody.trim().isEmpty) return rawBody;

    String sanitized = rawBody;

    // 1. Redact OTPs and verification codes
    sanitized = sanitized.replaceAllMapped(_otpRegex, (match) {
      return match.group(0)!.replaceAll(match.group(1)!, '[REDACTED_OTP]');
    });

    // 2. Redact full 8-16 digit account numbers (preserve last 4 digits if present)
    sanitized = sanitized.replaceAllMapped(_fullAccountRegex, (match) {
      final fullNum = match.group(1)!;
      final last4 = fullNum.length >= 4 ? fullNum.substring(fullNum.length - 4) : 'XXXX';
      return match.group(0)!.replaceAll(fullNum, 'XXXXXX$last4');
    });

    return sanitized;
  }
}
