from pydantic import BaseModel, Field
from typing import Optional

class Expense(BaseModel):
    amount: Optional[str] = Field(
        default=None,
        description="The monetary amount spent or transacted, extracted as a string."
    )

    merchant: Optional[str] = Field(
        default=None,
        description="The name of the vendor, store, merchant, or person where the money was spent."
    )

    currency: Optional[str] = Field(
        default=None,
        description="The currency symbol or code used for the transaction (e.g., INR, USD, Rs, $)."
    )