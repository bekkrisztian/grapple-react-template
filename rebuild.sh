if [[ -z "${REACT_APP_REMOTE_URL}" ]] && [[ "${REMOTE_ENTRY_URL}" != "" ]]; then
    export REACT_APP_REMOTE_URL=$(echo ${REMOTE_ENTRY_URL} | sed "s,/remoteEntry.js,,g")
fi

if [[ -z "${CONTAINER_NAME}" ]]; then
    export CONTAINER_NAME=$(curl -s -k $REACT_APP_REMOTE_URL/dashboard.json | jq -r '.name')
    echo "CONTAINER_NAME: ${CONTAINER_NAME}"
fi

echo "REACT_APP_REMOTE_URL = ${REACT_APP_REMOTE_URL}"

echo "testing: curl -k -Is ${REACT_APP_REMOTE_URL}/dashboard.json | head -1"
# timeout 600 sh -c "while ! curl -k -Is ${REACT_APP_REMOTE_URL}/dashboard.json 2>/dev/null | head -1 | grep 200; do sleep 1; echo -n '.'; done" || echo "\n\nERROR: could not reach: ${REACT_APP_REMOTE_URL}/dashboard.json after 10 minutes"
while ! curl -k -Is ${REACT_APP_REMOTE_URL}/dashboard.json 2>/dev/null | head -1 | grep 200; do
    sleep 1
    echo -n '.'
done || echo "\n\nERROR: could not reach: ${REACT_APP_REMOTE_URL}/dashboard.json after 10 minutes"

echo "testing: curl -k ${REACT_APP_REMOTE_URL}/dashboard.json | jq ."
echo "wait until it is returning a json object..."
while ! curl -k ${REACT_APP_REMOTE_URL}/dashboard.json 2>/dev/null | jq . >/dev/null; do
    sleep 1
    echo -n '.'
done || echo "\n\nERROR: ${REACT_APP_REMOTE_URL} did not return a json object..."
    
if [[ -z "${DEV}" ]]; then
    pnpm build
    cp /app/dist/* /usr/share/nginx/html/.
    nginx -g 'daemon off;'
else
    sleep 1
    pnpm dev
fi
