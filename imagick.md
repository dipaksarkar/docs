## Install PHP's Imagick Extension on macOS

```bash
brew install php
brew install imagemagick
brew install pkg-config
pecl install imagick
```

The first things to do are to install Imagick and pkg-config. The PHP extension depends on Imagick as it’s effectively a C wrapper around it. PECL needs pkg-config to install and compile the extension. To install them using Homebrew, run the following command.

```bash
brew install imagemagick
brew install pkg-config
```

Allowing for the speed of your internet connection and your Mac’s hardware, this should only take a minute or so.

Use Pecl to install the Imagick extension
The next thing to do is to install the Imagick extension using PECL, by running the following command; you may have to use sudo, if you’re on macOS, Linux, or *BSD.

pecl install imagick
You don’t have to install PECL directly, as it’s installed by Homebrew as part of installing PHP.

When the installation’s complete, you should see output similar to the following at the bottom of the command’s terminal output.

```bash
Build process completed successfully
Installing '/usr/local/Cellar/php@8.1/8.1.20_2/include/php/ext/imagick/php_imagick_shared.h'
Installing '/usr/local/Cellar/php@8.1/8.1.20_2/pecl/20210902/imagick.so'
install ok: channel://pecl.php.net/imagick-3.7.0
Extension imagick enabled in php.ini
If so, the extension was successfully installed.
```

Check that the extension’s installed
Now, like most things when it comes to computers, it’s good to check. So, if you run the following command, you should see imagick printed to the terminal.

php -m
If you have grep installed and want to save yourself some time and effort, scanning through the list of extensions printed to the terminal, run the following command instead.

php -m | grep imagick
That’s how to install PHP’s Imagick extension on macOS
So, if you’re developing with PHP on macOS and need to install the Imagick extension, that’s the short guide on how to. To be fair, I’ve only tested it on PHP 8.1, as that is the version of PHP I currently have installed. So, for other versions, you mileage may vary.

