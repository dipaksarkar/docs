### 1. Install Homebrew. Execute the following shell command in your terminal:

``` bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

If you have Homebrew already installed, update it:

``` bash
brew update
```

### 2. Install composer and Valet. Execute the following shell commands in your terminal:

``` bash
brew install composer
```
    
Now lets install Laravel Valet using composer:

```
composer global require laravel/valet
valet install
```

### 3. Install phpMyAdmin using Homebrew. Execute the following shell command in your terminal:

```
brew install phpmyadmin
```

### 4. Register phpMyAdmin path with Laravel Valet. Execute the following shell commands in your terminal:

```
cd /usr/local/share/phpmyadmin
valet domain test
valet link
```

Now you can access phpMyAdmin in your favorite browser via http://phpmyadmin.test.