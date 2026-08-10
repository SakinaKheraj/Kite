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
                "You are an expert financial SMS extraction algorithm. "
                "Extract the exact monetary amount spent/debited/credited, category (Food, Travel, Utilities, Entertainment, SMS), "
                "and a descriptive string explaining WHERE or WHAT the money was spent on (e.g. 'Uber ride to airport', 'Swiggy order', 'Electricity bill payment'). "
                "CRITICAL: Completely IGNORE any OTP numbers, PINs, or verification codes present in the text when determining amounts."
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
                if result and result.amount:
                    return result
            except Exception as ex:
                print(f"WARNING: LLM invocation failed ({ex}). Falling back to regex extraction...")

        return self._fallback_extract(message)

    def _fallback_extract(self, text: str) -> Expense:
        # Pre-clean: strip OTP numbers so they are never parsed as transaction amounts
        text_clean = re.sub(
            r'\b(?:otp|one time password|verification code|secret code|auth code|cvv|password|pin|valid for)\b[\s:=-]*[0-9]{4,8}',
            '',
            text,
            flags=re.IGNORECASE
        )

        # Regex for Amount (e.g. INR 450.00, Rs 1200, ₹450, 450.00)
        amount_match = re.search(r'(?:inr|rs\.?|₹|\$)\s*([\d,]+(?:\.\d{1,2})?)', text_clean, re.IGNORECASE)
        if not amount_match:
            amount_match = re.search(r'([\d,]+\.\d{2})', text_clean)
        
        amount_val = "0.0"
        if amount_match:
            amount_val = amount_match.group(1).replace(',', '')

        text_lower = text.lower()
        desc_val = ""

        # Extract "for <purpose>" or "at <merchant>"
        purpose_match = re.search(r'(?:for|at|towards)\s+([A-Za-z0-9\s\-_]+?)(?=\s+(?:via|using|from|ending|card|upi|on|ref|txn|transaction|successful|\.|$))', text_clean, re.IGNORECASE)
        if purpose_match:
            desc_val = purpose_match.group(1).strip()

        if not desc_val or len(desc_val) < 2:
            if "uber" in text_lower:
                desc_val = "Uber ride"
            elif "swiggy" in text_lower:
                desc_val = "Swiggy order"
            elif "zomato" in text_lower:
                desc_val = "Zomato order"
            elif "electricity" in text_lower or "bill" in text_lower:
                desc_val = "Electricity Bill Payment"
            else:
                desc_val = "Card / Bank Transaction"

        # Heuristic for category selection
        category_val = "SMS"
        if any(k in text_lower for k in ["swiggy", "zomato", "restaurant", "food", "dining", "cafe", "dominos", "kfc", "mcdonald"]):
            category_val = "Food"
        elif any(k in text_lower for k in ["uber", "ola", "flight", "airline", "railway", "irctc", "fuel", "petrol", "cab", "travel", "auto", "ride"]):
            category_val = "Travel"
        elif any(k in text_lower for k in ["electricity", "bill", "water", "recharge", "airtel", "jio", "vi", "bescom", "utility"]):
            category_val = "Utilities"
        elif any(k in text_lower for k in ["movie", "cinema", "pvr", "inox", "bookmyshow", "netflix", "prime", "spotify"]):
            category_val = "Entertainment"
        else:
            category_val = "SMS"

        return Expense(
            amount=amount_val,
            category=category_val,
            merchant=desc_val,
            description=desc_val,
            currency="INR"
        )