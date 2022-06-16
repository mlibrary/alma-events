# Alma Webhook

A server that listens for webhook posts from Alma.

## Setting up Alma Webhook for development

Clone the repo

```
git clone git@github.com:mlibrary/alma_webhook.git
cd alma_webhook
```

build web container
```
docker-compose build web
```

set up your .env file
```
cp .env-example .env
```

Replace the value for `BUNDLE_RUBYGEMS__PKG__GITHUB__COM` in the `.env` file with your [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) that has `read:packages` access. 

bundle install gems to a docker volume
```
docker-compose run --rm web bundle install
```
generate ssh-keys
```
./set_up_development_ssh_keys
```

start containers
```
docker-compose up -d
```

In a browser, go to http://localhost:4567 to see the website.

## Running tests
```
docker-compose run --rm web bundle exec rspec
```

## Trying out message queue
While in development mode and while the app is `up` one can send a message directly to the message queue by doing the following:
```
docker-compose exec web curl -X POST --data-binary "@PATH_TO_YOUR_MESSAGE_JSON" localhost:4567/send-dev-webhook-message
```

# Kubernetes Configuration
The Kubernetes deployment configuration lives in [alma-utilities-kube](https://github.com/mlibrary/alma-utilities-kube)
