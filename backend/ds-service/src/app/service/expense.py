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

    category: Optional[str] = Field(
        default="SMS",
        description="Category of the expense, e.g. Food, Travel, Utilities, Entertainment, SMS."
    )

    description: Optional[str] = Field(
        default=None,
        description="A short descriptive sentence summarizing where or what the expense was spent on (e.g. Uber ride to airport, Swiggy order, Electricity bill payment)."
    )

    currency: Optional[str] = Field(
        default="INR",
        description="The currency symbol or code used for the transaction (e.g., INR, USD, Rs, $)."
    )