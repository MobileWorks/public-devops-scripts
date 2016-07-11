#!/bin/bash

if [ -n "$NEW_RELIC_API_KEY" ]; then
    echo "Notifying NewRelic"
    curl -sX POST "https://api.newrelic.com/v2/applications/$NEW_RELIC_APPLICATION_ID/deployments.json" \
        -H "X-Api-Key:$NEW_RELIC_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"deployment\": {\"revision\": \"$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM\", \"description\": \"$CIRCLE_PROJECT_REPONAME\"}}"
    echo ""
else
    echo "Variable is Unset - NEW_RELIC_API_KEY"
fi

if [ -n "$SENTRY_API_KEY" ]; then
    echo "Notifying Sentry"
    curl -sX POST "https://app.getsentry.com/api/0/projects/$SENTRY_PROJECT_PATH/releases/" \
        -H "Authorization: Bearer $SENTRY_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"version\": \"$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM\", \"url\": \"$CIRCLE_BUILD_URL\"}"
    echo ""
else
    echo "Variable is Unset - SENTRY_API_KEY"
fi
