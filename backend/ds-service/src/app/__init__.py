import os
import json
from flask import Flask, request, jsonify
from dotenv import load_dotenv
from app.service.messageService import MessageService
from kafka import KafkaProducer
from kafka.errors import KafkaError
import jsonpickle

load_dotenv()
app = Flask(__name__)
app.config.from_pyfile('config.py', silent=True)

message_service = MessageService()

# Fetches KAFKA_HOST and KAFKA_PORT set in services.yml, falling back to defaults if run directly
KAFKA_HOST = os.environ.get('KAFKA_HOST', 'localhost')
KAFKA_PORT = os.environ.get('KAFKA_PORT', '9092')
KAFKA_BOOTSTRAP_SERVERS = f"{KAFKA_HOST}:{KAFKA_PORT}"

# --- Resilient Kafka Producer Setup ---
try:
    producer = KafkaProducer(
        bootstrap_servers=[KAFKA_BOOTSTRAP_SERVERS],
        value_serializer=lambda v: json.dumps(v).encode('utf-8'),
        request_timeout_ms=5000,
        metadata_max_age_ms=30000
    )
    print(f"SUCCESS: Connected to Kafka Broker on {KAFKA_BOOTSTRAP_SERVERS}")
except Exception as e:
    print(f"WARNING: Kafka Broker unavailable at startup ({e}). Retrying on execution block.")
    producer = None

@app.route('/v1/ds/message', methods=['POST'])
def hanleMessage():
    global producer
    data = request.get_json(silent=True)
    if not data or 'message' not in data:
        return jsonify({"status": "error", "error": "Missing 'message' key in request body"}), 400
    
    message = data.get('message')
    result = message_service.process_msg(message)

    if result is None:
        return jsonify({"status": "ignored", "reason": "Non-transactional text filtered out."}), 200
    
    # Lazy fallback initialization check if the startup connection dropped
    if producer is None:
        try:
            producer = KafkaProducer(
                bootstrap_servers=[KAFKA_BOOTSTRAP_SERVERS],
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                request_timeout_ms=5000
            )
        except Exception as e:
            return jsonify({"status": "error", "error": f"Kafka connection down: {str(e)}"}), 503

    # Safely serialize and send to Kafka
    # Uses model_dump() / dict conversion to cleanly package JSON payload
    serialized_result = result.model_dump() if hasattr(result, 'model_dump') else result.dict()
    
    try:
        future = producer.send('expense_service', serialized_result)
        future.get(timeout=5)  # Force synchronous check
    except Exception as kafka_ex:
        return jsonify({"status": "error", "message": f"Failed to push message to Kafka: {str(kafka_ex)}"}), 500

    return jsonify(serialized_result), 200

@app.route('/', methods=['GET'])
def handleGet():
    return jsonify({"message": "Hello World"}), 200

if __name__ == "__main__":
    # Host changed to '0.0.0.0' and port to 8010 so Docker can bind & route requests
    SERVER_PORT = int(os.environ.get('PORT', 8010))
    app.run(host="0.0.0.0", port=SERVER_PORT, debug=True)