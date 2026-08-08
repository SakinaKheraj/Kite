import os
import re
from langchain_core.prompts import ChatPromptTemplate
from langchain_mistralai import ChatMistralAI
from app.service.expense import Expense

class LLMService:
    def __init__(self):
        self.prompt = ChatPromptTemplate.from_messages([
            (
                "system",
                "You are an expert extraction algorithm. "
                "Only extract relevant information from the text. "
                "If you do not know the value of an attribute asked to extract, "
                "return null for the attribute's value."
            ),
            ("human", "{text}")
        ])

        self.apiKey = os.getenv('MISTRAL_API_KEY')
        self.llm = None
        self.runnable = None
        if self.apiKey and self.apiKey != "MISTRAL_KEY_GOES_HERE":
            try:
                self.llm = ChatMistralAI(api_key=self.apiKey, model="open-mistral-7b")
                self.runnable = self.prompt | self.llm.with_structured_output(schema=Expense)
            except Exception as e:
                print(f"WARNING: Could not initialize ChatMistralAI ({e})")

    def runLLM(self, message: str) -> Expense:
        if self.runnable:
            try:
                result = self.runnable.invoke({"text": message})
                if result:
                    return result
            except Exception as ex:
                print(f"WARNING: LLM invocation failed ({ex}). Falling back to regex extraction...")

        return self._fallback_extract(message)

    def _fallback_extract(self, text: str) -> Expense:
        # Regex for Amount (e.g. INR 450.00, Rs 1200, 450.00)
        amount_match = re.search(r'(?:inr|rs\.?|₹|\$)\s*([\d,]+(?:\.\d{1,2})?)', text, re.IGNORECASE)
        if not amount_match:
            amount_match = re.search(r'([\d,]+\.\d{2})', text)
        
        amount_val = "0.0"
        if amount_match:
            amount_val = amount_match.group(1).replace(',', '')

        # Category and Merchant detection heuristic
        category_val = "Other"
        merchant_val = "Bank Transaction"
        text_lower = text.lower()

        if any(k in text_lower for k in ["swiggy", "zomato", "restaurant", "food", "dining", "cafe", "dominos", "kfc", "mcdonald"]):
            category_val = "Food"
            merchant_val = "Swiggy" if "swiggy" in text_lower else ("Zomato" if "zomato" in text_lower else "Food & Dining")
        elif any(k in text_lower for k in ["uber", "ola", "flight", "airline", "railway", "irctc", "fuel", "petrol", "cab", "travel", "auto"]):
            category_val = "Travel"
            merchant_val = "Uber" if "uber" in text_lower else ("Ola" if "ola" in text_lower else "Travel")
        elif any(k in text_lower for k in ["electricity", "bill", "water", "recharge", "airtel", "jio", "vi", "bescom", "utility"]):
            category_val = "Utilities"
            merchant_val = "Utility Bill"
        elif any(k in text_lower for k in ["movie", "cinema", "pvr", "inox", "bookmyshow", "netflix", "prime", "spotify"]):
            category_val = "Entertainment"
            merchant_val = "Entertainment"
        else:
            merchant_match = re.search(r'(?:at|vpa|to|info)\s+([A-Za-z0-9_\-\.]+)', text, re.IGNORECASE)
            if merchant_match:
                merchant_val = merchant_match.group(1)

        return Expense(
            amount=amount_val,
            category=category_val,
            merchant_name=merchant_val,
            currency="INR"
        )