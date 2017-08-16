# Catching https://github.com/boxcutter/ubuntu/issues/73
sudo systemctl disable apt-daily.service # disable run when system boot
sudo systemctl disable apt-daily.timer   # disable timer run
sudo systemctl stop apt-daily.timer   # disable timer run
sudo systemctl stop apt-daily.service   # disable timer run
