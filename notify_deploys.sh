#!/bin/bash
# Required environment variables:
# NEW_RELIC_API_KEY         (see https://rpm.newrelic.com/accounts/{account_id}/integrations?page=api_keys)
# NEW_RELIC_APPLICATION_ID  (eg. 12345678)
# SENTRY_API_KEY            (see https://app.getsentry.com/api/)
# SENTRY_PROJECT_PATH       (eg. Leadgenius/PROJECT_NAME)
# MAILGUN_API_KEY           (see https://mailgun.com/app/account/settings)

# Environment variables sourced from CircleCi:
# CIRCLE_PROJECT_REPONAME   (eg. reponame)
# CIRCLE_BUILD_NUM          (eg. 123)
# CIRCLE_BUILD_URL          (eg. https://circleci.com/gh/MobileWorks/reponame/123)
# CIRCLE_COMPARE_URL        (eg. https://github.com/MobileWorks/reponame/compare/aabbccdd...aabbccdd)

set -e

echo "Notifying NewRelic:"
if [ -n "$NEW_RELIC_API_KEY" ]; then
    curl -sX POST "https://api.newrelic.com/v2/applications/$NEW_RELIC_APPLICATION_ID/deployments.json" \
        -H "X-Api-Key:$NEW_RELIC_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"deployment\": {\"revision\": \"$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM\", \"description\": \"$CIRCLE_PROJECT_REPONAME\"}}"
    echo ""
else
    echo "Variable is Unset - NEW_RELIC_API_KEY"
fi

echo "Notifying Sentry:"
if [ -n "$SENTRY_API_KEY" ]; then
    curl -sX POST "https://app.getsentry.com/api/0/projects/$SENTRY_PROJECT_PATH/releases/" \
        -H "Authorization: Bearer $SENTRY_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"version\": \"$CIRCLE_PROJECT_REPONAME-$CIRCLE_BUILD_NUM\", \"url\": \"$CIRCLE_BUILD_URL\", \"environment\": \"production\"}"
    echo ""
else
    echo "Variable is Unset - SENTRY_API_KEY"
fi

echo "Sending Email Notification:"
if [ -n "$MAILGUN_API_KEY" ]; then
    curl -sX POST https://api.mailgun.net/v3/leadgeni.us/messages \
        -u "api:$MAILGUN_API_KEY" \
        -F from='Deployments <postmaster@leadgeni.us>' \
        -F to='product@leadgenius.com' \
        -F subject="Deployment: $CIRCLE_PROJECT_REPONAME" \
        -F text="Your friendly neighborhood LG engineering team just deployed a new version." \
        --form-string html="<p>Your friendly neighborhood LG engineering team just deployed a new version. &#128588;</p><p>Changes since last deployment:<br>$CIRCLE_COMPARE_URL</p>"
    echo ""
else
    echo "Variable is Unset - MAILGUN_API_KEY"
fi
