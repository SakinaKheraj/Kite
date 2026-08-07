FROM python:3.12-slim
WORKDIR /app

# Copy the exact distribution archive generated in dist/
COPY dist/dsservice-0.1.0.tar.gz .

# Install the distribution package
RUN pip install --no-cache-dir dsservice-0.1.0.tar.gz

# Set the environment variable for the Flask app
ENV FLASK_APP=src/app/__init__.py

# Expose port
EXPOSE 8010

# Start the Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=8010"]