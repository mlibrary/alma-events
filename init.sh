if [ -f ".env" ]; then
  echo "🌎 .env exists. Leaving alone"
else
  echo "🌎 .env does not exist. Copying .env-example to .env"
  cp env.example .env
  YOUR_UID=$(id -u)
  YOUR_GID=$(id -g)
  echo "🙂 Setting your UID (${YOUR_UID}) and GID (${YOUR_UID}) in .env"
  docker run --rm -v ./.env:/.env alpine echo "$(sed s/YOUR_UID/${YOUR_UID}/ .env)" >.env
  docker run --rm -v ./.env:/.env alpine echo "$(sed s/YOUR_GID/${YOUR_GID}/ .env)" >.env
fi

echo "🚢 Build docker images"
docker compose build

echo "⬇️ Pull dependent service images"
docker compose pull

echo "📦 Installing Gems"
docker compose run --rm app bundle install

ssh_key_count=`find ./sftp/ssh -type f  -name ssh_client_rsa_key | wc -l`
if [ $ssh_key_count == 1 ]; then
  echo "🔑 development ssh keys exist. Not re-running"
else
  echo "🔑 setting up development ssh keys"
  ./set_up_development_ssh_keys.sh
fi
