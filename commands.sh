# Starts localstack in detached mode
docker-compose up -d

# Starts  localstack in atached mode.
docker-compose up

# Stops localstack
docker-compose down

# Test it works correctly
aws --endpoint-url=http://localhost:4566 sns list-topics --region eu-west-1

# Recommended to set this env variable always
TOPIC_ARN=arn:aws:sns:eu-west-1:000000000000:gsm-adverts-table-change
# hostname -I gives the IP of the WSL VM, it's required in order to make sure
# SNS is able to dispatch the notification. If we use localhost SNS will try
# to connect to another container. And it seems like host.docker.internal is not working
# from WSL.
# Note how we are connecting the container to the host machine, this workaround is to make 
# sure docker reach the correct ip.
# https://github.com/docker/for-win/issues/5167
# https://github.com/docker/for-win/issues/5167#issuecomment-556471031
# The | xargs is to remove (trim) whitespaces at begining and end.
# https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable
NOTIFICATION_ENDPOINT=http://$(hostname -I | xargs):3000/update-customer
# NOTIFICATION_ENDPOINT=http://localhost:3000/refresh-customer-data-in-config
# NOTIFICATION_ENDPOINT=http://192.168.65.2:3000/refresh-customer-data-in-config
# To understand the host.docker.internal see: https://docs.docker.com/desktop/mac/networking/
# NOTIFICATION_ENDPOINT=http://host.docker.internal:3000/refresh-customer-data-in-config
# NOTIFICATION_ENDPOINT=http://172.19.9.76:3000/refresh-customer-data-in-config

# Add a new subscription.
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn $TOPIC_ARN --protocol http --notification-endpoint $NOTIFICATION_ENDPOINT --region eu-west-1

# List all subscriptions
aws --endpoint-url=http://localhost:4566 sns list-subscriptions --region eu-west-1

# Unsubscribe
aws --endpoint-url=http://localhost:4566 sns unsubscribe --subscription-arn arn:aws:sns:eu-west-1:000000000000:gsm-adverts-table-change:cfb10efa-d7bb-4d49-98e7-25dd5820c998 --region eu-west-1

# Publish a message.
aws --endpoint-url=http://localhost:4566 sns publish --topic-arn $TOPIC_ARN --message file://message.json --region eu-west-1
aws --endpoint-url=http://localhost:4566 sns publish --topic-arn $TOPIC_ARN --message "Hello world" --region eu-west-1

chmod +x ./restart-topic.sh
