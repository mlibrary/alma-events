# Alma Webhook

A server that listens for webhook posts from Alma.

## Setting up Alma Webhook for development

Clone the repo

```
git clone git@github.com:mlibrary/alma_webhook.git
cd alma_webhook
```

copy .env-example to .env

```
cp .env-example .env
```

edit .env with the following environment variables. 

```ruby
#.env/development/web
ALMA_WEBHOOK_SECRET='YOURWEBHOOKSECRET'
```

build web container

```
docker-compose build web
```

bundle install
```
docker-compose run --rm web bundle install
```

start containers

```
docker-compose up -d
```

In a browser, go to http://localhost:4567 to see the website.

# Kubernetes Configuration
The Kubernetes deployment configuration libes in [Alma-Apps-Kube](https://github.com/mlibrary/alma-apps-kube)
