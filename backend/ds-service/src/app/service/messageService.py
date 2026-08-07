from app.service.llmService import LLMService
from app.utils.messageUtil import MessageUtil
from app.service.expense import Expense

class MessageService:
    def __init__(self):
        self.messageUtil = MessageUtil()
        self.llmService = LLMService()

    def process_msg(self, sms_content: str) -> Expense | None:
        is_transactional = self.messageUtil.isBankSms(sms_content)
        if not is_transactional:
            print(f"DEBUG: Message skipped (not a transaction): {sms_content[:30]}...")
            return None
        
        print("DEBUG: Valid transaction text detected. Forwarding to Mistral AI...")
        expense_data = self.llmService.runLLM(sms_content)
        return expense_data