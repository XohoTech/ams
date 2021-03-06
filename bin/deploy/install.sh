#!/bin/bash -le
sudo yum -y update
source /etc/profile
echo "Running Deployment for ID: $DEPLOYMENT_ID"
export APP_HOME=/var/www/ams
sudo chown -R ec2-user:ec2-user $APP_HOME
cd $APP_HOME
echo "Ensuring bundler is installed..."
gem install bundler
bundle install --deployment --without development test
echo "ruby version:`ruby -v`"
echo "rails versions:`bundle exec rails -v`"
echo "node version:`node -v`"
echo "yarn version:`yarn -v`"
if [ -z $SECRET_KEY_BASE ]; then
  sudo echo "export SECRET_KEY_BASE=`bin/rails secret`" >> ~/.bashrc
  source ~/.bashrc
fi
bin/rails db:migrate
bin/rails assets:precompile

bin/rails g deployment_info_page --deployment_id $DEPLOYMENT_ID
sudo service httpd restart
sleep 2
SIDEKIQ_RESET=true bundle exec ruby bin/scripts/ensure_sidekiq_running.rb
sleep 2
echo "End of install.sh"
exit 0;
