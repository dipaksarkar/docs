[DOCS](https://idroot.us/install-ioncube-loader-ubuntu-22-04/)

/usr/bin/php8.1 -i | grep extension_dir

sudo cp ioncube_loader_lin_8.3.so ioncube_loader_lin_8.3_ts.so /usr/lib/php/20230831
echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/fpm/conf.d/00-ioncube.ini
cat /etc/php/8.3/fpm/conf.d/00-ioncube.ini

echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20230831/ioncube_loader_lin_8.3.so" | sudo tee /etc/php/8.3/cli/conf.d/00-ioncube.ini
cat /etc/php/8.3/cli/conf.d/00-ioncube.ini

/etc/php/8.1/fpm/php.ini


cat /etc/php/8.1/fpm/conf.d/00-ioncube.ini
; configuration for php ioncube module
; priority=00
zend_extension=/usr/lib/php/20200930/ioncube_loader_lin_8.1.so
sudo nano /etc/php/8.1/fpm/php.ini

grep -inr ioncube /etc/php/7.0

rm /etc/php/8.3/cli/conf.d/00-ioncube.ini
rm /etc/php/8.3/fpm/conf.d/00-ioncube.ini


# Install ionCube Loader on Ubuntu 22.04

```bash
wget https://raw.githubusercontent.com/dipaksarkar/docs/refs/heads/master/hestiacp/install_ioncube.sh
chmod +x install_ioncube.sh
./install_ioncube.sh
```