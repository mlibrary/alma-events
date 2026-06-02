# Alma Webhook

A server that listens for webhook posts from Alma.

## Setting up Alma Webhook for development

Clone the repo

```
git clone git@github.com:mlibrary/alma-events.git
cd alma-events
```

run the init script

```
./init.sh
```

edit .env with actual environment variables; ask a developer if you need them


start containers
```
docker compose up -d
```

In a browser, go to http://localhost:4567 to see the website.

## Running tests
```
docker compose run --rm web bundle exec rspec
```

## Trying out message queue
While in development mode and while the app is `up` one can send a message directly to the message queue by doing the following:
```
docker compose exec web curl -X POST --data-binary "@PATH_TO_YOUR_MESSAGE_JSON" localhost:4567/send-dev-webhook-message
```

## Local ssh keys script

SSH keys are generated the first time you run the `init.sh`. If your ssh keys get messed up you can rerun the script specifically for generating them:

```
./set_up_development_ssh_keys
```

## Kubernetes Configuration
The Kubernetes deployment configuration lives in in the `environments/alma-events` directory in: 
* [aim-kube](https://github.com/mlibrary/aim-kube)
* [search-kube](https://github.com/mlibrary/search-kube)
