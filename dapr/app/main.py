from time import sleep
import logging
from dapr.clients import DaprClient

logging.basicConfig(level = logging.INFO)

BINDING_NAME = 'helloworld'
BINDING_OPERATION = 'get'

while True:
    with DaprClient() as client:
        resp = client.invoke_binding(BINDING_NAME, BINDING_OPERATION, '')
    logging.basicConfig(level = logging.INFO)
    logging.info('Response: %s', resp.data)
    sleep(5)