# Installs Chef Server on a local machine, using Chef Solo.
# https://docs.chef.io/install_server.html#standalone
# https://github.com/chef-cookbooks/chef-server

# install chef-solo
curl -L https://www.chef.io/chef/install.sh | sudo bash
# create required bootstrap dirs/files
sudo mkdir -p /var/chef/cache /var/chef/cookbooks
# pull down this chef-server cookbook
wget -qO- https://supermarket.chef.io/cookbooks/chef-server/download | sudo tar xvzC /var/chef/cookbooks
# pull down dependency cookbooks
for dep in chef-ingredient
do
  wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | sudo tar xvzC /var/chef/cookbooks
done
# GO GO GO!!!
# sudo chef-solo -o 'recipe[chef-server::default]'
sudo chef-solo -j /tmp/config.json

sudo chef-server-ctl install chef-manage
sudo chef-server-ctl reconfigure
sudo chef-manage-ctl reconfigure --accept-license
