#!/bin/bash

LOGIC_APP_URL='https://prod-180.westus.logic.azure.com:443/workflows/325d57902a2b4953a11888d54569336f/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=wPDsEv9IeAWJJgiah5y2Gu_1LDS1AZJ6VANMlAlcS54'

MAX_RETRIES=5
attempt=0

while [ $attempt -lt $MAX_RETRIES ]; do
    response=$(/usr/bin/curl -s -o /dev/null -w "%{http_code}" -d '{"Subnet": "Black5Subnet", "VM": "Black5", "Status": "Online"' -H "Content-Type: application/json" $LOGIC_APP_URL)

    if [ "$response" -eq 202 ]; then
        /usr/bin/echo "Successfully send data to Logic App"
        break
    else
        /usr/bin/echo "Failed to send data with response code: $response, attempt $((attempt + 1)) of $MAX_RETRIES"
        attempt=$((attempt + 1))
        /usr/bin/sleep 2 # Wait 2 secs before retrying
    fi
done

if [ "$attempt" -eq $MAX_RETRIES ]; then
    /usr/bin/echo "Failed to send data after $MAX_RETRIES attempts"
fi