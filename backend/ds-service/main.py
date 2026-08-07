import os
import sys
import json
from typing import Optional, Dict, Any
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
from dotenv import load_dotenv

# Ensure `src` directory is on the python search path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "src"))

from app.service.messageService import MessageService
from kafka import KafkaProducer

load_dotenv()

app = FastAPI(
    title="DS Service",
    description="Data Science & ML Analytics Microservice for Expense Tracker",
    version="1.0.0"
)

# Global Kafka Producer state
KAFKA_HOST = os.environ.get('KAFKA_HOST', 'localhost')
KAFKA_PORT = os.environ.get('KAFKA_PORT', '9092')
KAFKA_BOOTSTRAP_SERVERS = f"{KAFKA_HOST}:{KAFKA_PORT}"

producer = None

def get_kafka_producer():
    global producer
    if producer is None:
        try:
            producer = KafkaProducer(
                bootstrap_servers=[KAFKA_BOOTSTRAP_SERVERS],
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                request_timeout_ms=5000,
                metadata_max_age_ms=30000
            )
            print(f"SUCCESS: Connected to Kafka Broker on {KAFKA_BOOTSTRAP_SERVERS}")
        except Exception as e:
            print(f"WARNING: Kafka Broker unavailable at startup ({e}).")
            producer = None
    return producer

# Initialize Kafka producer on startup attempt
get_kafka_producer()

message_service = MessageService()

# --- Pydantic Data Schemas ---

class HealthResponse(BaseModel):
    status: str = Field(..., example="healthy")
    service: str = Field(..., example="ds-service")

class PredictRequest(BaseModel):
    message: Optional[str] = Field(None, description="Raw transaction SMS or text message to analyze")
    amount: Optional[float] = Field(None, description="Historical or proposed transaction amount")
    category: Optional[str] = Field(None, description="Expense category")
    features: Optional[Dict[str, Any]] = Field(None, description="Optional feature vector for prediction models")

class PredictResponse(BaseModel):
    status: str = Field(..., example="success")
    prediction: Dict[str, Any] = Field(..., description="Extracted details or predicted category/metrics")
    confidence: float = Field(default=0.95, description="Model prediction confidence score")

class MessageRequest(BaseModel):
    message: str = Field(..., description="Transaction message payload")

# --- Routes ---

@app.get("/health", response_model=HealthResponse, tags=["Health"])
def health_check():
    """Health check endpoint exposing microservice status."""
    return HealthResponse(status="healthy", service="ds-service")

@app.get("/", tags=["Root"])
def root():
    """Root endpoint for basic verification."""
    return {"message": "Hello World", "service": "ds-service"}

@app.post("/analytics/predict", response_model=PredictResponse, tags=["Analytics"])
def predict_analytics(payload: PredictRequest):
    """
    Analyzes input payloads (SMS text, transaction amount, category, or features)
    and returns a structured prediction response using Pydantic.
    """
    prediction_result = {}

    if payload.message:
        extracted = message_service.process_msg(payload.message)
        if extracted:
            prediction_result["extracted_expense"] = extracted.model_dump() if hasattr(extracted, 'model_dump') else extracted.dict()
            prediction_result["is_transactional"] = True
        else:
            prediction_result["is_transactional"] = False
            prediction_result["note"] = "Non-transactional text filtered out."
    
    if payload.amount is not None:
        prediction_result["analyzed_amount"] = payload.amount
        prediction_result["spending_insight"] = "High priority expense" if payload.amount > 500 else "Standard routine expense"
    
    if payload.category:
        prediction_result["predicted_category"] = payload.category
    
    if payload.features:
        prediction_result["feature_summary"] = payload.features

    return PredictResponse(
        status="success",
        prediction=prediction_result,
        confidence=0.95 if payload.message or payload.amount else 0.80
    )

@app.post("/v1/ds/message", tags=["Message Processing"])
def handle_message(payload: MessageRequest):
    """
    Preserved message endpoint for processing transaction text and publishing
    extracted expense events to Kafka topic 'expense_service'.
    """
    prod = get_kafka_producer()
    result = message_service.process_msg(payload.message)

    if result is None:
        return {"status": "ignored", "reason": "Non-transactional text filtered out."}

    if prod is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Kafka broker connection unavailable."
        )

    serialized_result = result.model_dump() if hasattr(result, 'model_dump') else result.dict()
    try:
        future = prod.send('expense_service', serialized_result)
        future.get(timeout=5)
    except Exception as kafka_ex:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to push message to Kafka: {str(kafka_ex)}"
        )

    return serialized_result
