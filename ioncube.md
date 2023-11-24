[DOCS](https://idroot.us/install-ioncube-loader-ubuntu-22-04/)

/usr/bin/php8.1 -i | grep extension_dir

sudo cp ioncube_loader_lin_8.1.so ioncube_loader_lin_8.1_ts.so /usr/lib/php/20200930
echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20200930/ioncube_loader_lin_8.1.so" | sudo tee /etc/php/8.1/fpm/pool.d/00-ioncube.ini
cat /etc/php/8.1/fpm/pool.d/00-ioncube.ini

/etc/php/8.1/fpm/php.ini


cat /etc/php/8.1/fpm/conf.d/00-ioncube.ini
; configuration for php ioncube module
; priority=00
zend_extension=/usr/lib/php/20200930/ioncube_loader_lin_8.1.so
sudo nano /etc/php/8.1/fpm/php.ini

grep -inr ioncube /etc/php/7.0

rm /etc/php/8.2/cli/conf.d/00-ioncube.ini
rm /etc/php/8.2/fpm/conf.d/00-ioncube.ini