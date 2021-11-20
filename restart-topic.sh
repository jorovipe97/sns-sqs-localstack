TOPIC_NAME=gsm-adverts-table-change
TOPIC_ARN=arn:aws:sns:eu-west-1:000000000000:$TOPIC_NAME
NOTIFICATION_ENDPOINT=http://$(hostname -I | xargs):3000/refresh-customer-data-in-config

# Deletes the topic.
aws --endpoint-url=http://localhost:4566 sns delete-topic --topic-arn $TOPIC_ARN --region eu-west-1

# Create topic.
aws --endpoint-url=http://localhost:4566 sns create-topic --name $TOPIC_NAME --region eu-west-1
