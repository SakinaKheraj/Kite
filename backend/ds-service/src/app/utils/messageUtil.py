import re

class MessageUtil:
    def __init__(self):
        self.transaction_pattern = re.compile(
            r'(debit|credit|a/c|acct|account|spent|vpa|upi|inr|rs\.?|bal|balance|otp|received|transferred)', 
            re.IGNORECASE
        )

    def isBankSms(self, sms_content: str) -> bool:
        if not sms_content:
            return False

        return bool(self.transaction_pattern.search(sms_content))