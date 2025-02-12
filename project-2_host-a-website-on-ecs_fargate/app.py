# app.py
from flask import Flask
import os
import logging
app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route('/')
def hello():
    logger.info("Main route accessed")
    return 'Hello from ECS Fargate!'

@app.route('/health')
def health():
    logger.info("Health check performed")
    return 'OK', 200

@app.route('/version')
def version():
    logger.info("Version route accessed")
    return 'Version 1.1'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)