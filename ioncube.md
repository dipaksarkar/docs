/usr/bin/php7.4 -i | grep extension_dir

sudo cp ioncube_loader_lin_7.4.so ioncube_loader_lin_7.4_ts.so /usr/lib/php/20190902
echo -e "; configuration for php ioncube module\n; priority=00\nzend_extension=/usr/lib/php/20190902/ioncube_loader_lin_7.4.so" | sudo tee /etc/php/7.4/fpm/pool.d/00-ioncube.ini
cat /etc/php/7.4/fpm/pool.d/00-ioncube.ini

/etc/php/7.4/fpm/php.ini


cat /etc/php/7.4/fpm/conf.d/00-ioncube.ini
; configuration for php ioncube module
; priority=00
zend_extension=/usr/lib/php/20190902/ioncube_loader_lin_7.4.so
sudo nano /etc/php/7.4/fpm/php.ini