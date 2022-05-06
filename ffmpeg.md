Version Need:
ffmpeg version 4.2.2-1ubuntu1~18.04.york0

Command:
ffmpeg -re -i 'http://localhost/video/test.MP4' -vcodec libx264 -preset superfast -tune zerolatency -c:a aac -ar 44100 -f flv - | \
        ffmpeg -f flv -i - \
                -c copy -f flv 'rtmps://live-api-s.facebook.com:443/rtmp/1666331770203082?s_bl=1&s_sc=1666331800203079&s_sw=0&s_vt=api-s&a=AbyMU6XDFq7pGQnQ' \
                -c copy -f flv 'rtmps://live-api-s.facebook.com:443/rtmp/208171983957152?s_bl=1&s_sc=208172023957148&s_sw=0&s_vt=api-s&a=AbwRAFmaTeDi2M-Y'



screen -S JALCWfhteRvLTWFe -d -m ./public/storage/rtmp/JALCWfhteRvLTWFe.sh &
screen -X -S [session # you want to kill] quit


ffmpeg -re -i 'http://127.0.0.1:8000/storage/videos/t1kaMv3TF6Gvqhom.MP4' -vcodec libx264 -preset superfast -tune zerolatency -c:a aac -ar 44100 -f flv - | \
        ffmpeg -f flv -i -\
                -c copy -f flv 'rtmp://a.rtmp.youtube.com/live2/8c5a-66hk-dgds-7vba'\
                -c copy -f flv 'rtmp://rtmp.coderstm.com:1935/live/cVNWqySEqi2Rc6t7' &&
curl http://127.0.0.1:8000/stream/end/4

ffmpeg -i https://churchstreamlive.com/storage/videos/UqMp6TtrNAeeSB3c.mp4 -c:v libvpx -c:a libvorbis output.webm

ffmpeg -re -i https://churchstreamlive.com/storage/videos/UqMp6TtrNAeeSB3c.mp4 -c copy -f flv rtmps://live-api-s.facebook.com:443/rtmp/275224260146743?s_bl=1&s_sc=275224280146741&s_sw=0&s_vt=api-s&a=AbxzphtlErru_3bb

Curl Problem Fix:

sudo wget http://curl.haxx.se/download/curl-7.64.1.tar.gz
sudo tar -xvf curl-7.64.1.tar.gz
cd curl-7.64.1/
sudo ./configure
sudo make
sudo make install


* * * * * cd  && php artisan schedule:run >> /dev/null 2>&1

* * * * * php /var/www/rtmp/artisan schedule:run 1>> /dev/null 2>&1

For Laravel
https://hostadvice.com/how-to/how-to-enable-apache-mod_rewrite-on-an-ubuntu-18-04-vps-or-dedicated-server/

Php Myadmin
https://www.liquidweb.com/kb/install-phpmyadmin-ubuntu-18-04/

Upgrade Php on Ubuntu:

sudo apt install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update

sudo apt install php7.4

sudo apt install php7.4-fpm php7.4-curl php7.4-mbstring php7.4-mysql -y
sudo apt install php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl -y
sudo apt install php7.4 libapache2-mod-php7.4 php7.4-mbstring php7.4-xmlrpc php7.4-soap php7.4-gd php7.4-xml php7.4-cli php7.4-zip
sudo apt-get install libapache2-mod-php7.4

sudo a2dismod php7.2
sudo a2enmod php7.4
sudo service apache2 restart
sudo update-alternatives --set php /usr/bin/php7.4

<VirtualHost *:80>
        ServerAdmin admin@churchstreamlive.com
        ServerName rtmp
        ServerAlias www.rtmp
        # Redirect permanent / https://churchstreamlive.com/
        DocumentRoot /var/www/rtmp/public
        <Directory /var/www/rtmp/public>
                Options +FollowSymlinks
                AllowOverride All
                Require all granted
        </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>  

Add SSL
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/rtmp.key -out /etc/ssl/certs/rtmp.crt


FTP Create
sudo mkdir /home/coderstm/ftp/files
sudo chown coderstm:coderstm /home/coderstm/ftp/files

<Directory /var/www/rtmp/public>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
</Directory>

<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin admin@churchstreamlive.com

                DocumentRoot /var/www/rtmp/public
	        ServerName churchstreamlive.com/ www.churchstreamlive.com

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on

                SSLCertificateFile /etc/apache2/ssl/8f7da64fd6f5a7b8.crt
		SSLCertificateKeyFile /etc/apache2/ssl/8f7da64fd6f5a7b8.pem
		SSLCertificateChainFile /etc/apache2/ssl/gd_bundle-g2-g1.crt

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /var/www/rtmp/public>
                        Options +FollowSymlinks
                        AllowOverride All
                        Require all granted
                </Directory>

        </VirtualHost>
</IfModule>

<IfModule mod_ssl.c>
        <VirtualHost _default_:443>
                ServerAdmin admin@churchstreamlive.com
                ServerName churchstreamlive.com

                DocumentRoot /var/www/rtmp/public

                ErrorLog ${APACHE_LOG_DIR}/error.log
                CustomLog ${APACHE_LOG_DIR}/access.log combined

                SSLEngine on

                SSLCertificateFile /etc/ssl/8f7da64fd6f5a7b8.crt
		SSLCertificateKeyFile /etc/ssl/8f7da64fd6f5a7b8.pem
		SSLCertificateChainFile /etc/ssl/gd_bundle.crt

                <FilesMatch "\.(cgi|shtml|phtml|php)$">
                                SSLOptions +StdEnvVars
                </FilesMatch>
                <Directory /var/www/rtmp/public>
                        Options Indexes FollowSymlinks
                        AllowOverride All
                        Require all granted
                </Directory>
                <Directory /usr/lib/cgi-bin>
                                SSLOptions +StdEnvVars
                </Directory>

        </VirtualHost>
</IfModule>


Youtube Automation
Create Broadcast
curl --request POST \
  'https://www.googleapis.com/youtube/v3/liveBroadcasts?part=snippet%2CcontentDetails%2Cstatus&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"snippet":{"title":"Test broadcast","scheduledStartTime":"2020-04-29T12:31:2Z","scheduledEndTime":"2020-04-30T00:31:2Z"},"contentDetails":{"enableClosedCaptions":true,"enableContentEncryption":true,"enableDvr":true,"enableEmbed":true,"recordFromStart":true,"startWithSlate":true},"status":{"privacyStatus":"public"}}' \
  --compressed

Create LiveStream
curl --request POST \
  'https://www.googleapis.com/youtube/v3/liveStreams?part=snippet%2Ccdn%2CcontentDetails%2Cstatus&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data '{"snippet":{"title":"Your new video stream'"'"'s name","description":"A description of your video stream. This field is optional."},"cdn":{"frameRate":"60fps","ingestionType":"rtmp","resolution":"1080p"},"contentDetails":{"isReusable":true}}' \
  --compressed

Bind Broadcast 
curl --request POST \
  'https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?id=nwk_VUb-2xo&part=snippet&streamId=6NfBpcMhJlc23NaF6RzuVw1588148149292916&key=[YOUR_API_KEY]' \
  --header 'Authorization: Bearer [YOUR_ACCESS_TOKEN]' \
  --header 'Accept: application/json' \
  --compressed



ssh -i "churchstreamlive.pem" ubuntu@ec2-3-22-159-238.us-east-2.compute.amazonaws.com
ssh -i "Desktop/coderstm.pem" ubuntu@ec2-3-139-214-98.us-east-2.compute.amazonaws.com

// Copy files to server
scp -i "Desktop/coderstm.pem" "/Users/depok/Downloads/stream.thechurchplaybook.ssl.zip" ubuntu@ec2-3-139-214-98.us-east-2.compute.amazonaws.com: