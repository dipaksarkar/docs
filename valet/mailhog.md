# Setup mailhog with Laravel Valet
This article will show step by step on how to setup mailhog with Laravel Valet:
## 1. Install Homebrew.

Execute the following shell command in your terminal:

``` bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

If you have Homebrew already installed, update it:

``` bash
brew update
```

## 2. Install composer and Valet.

Execute the following shell commands in your terminal:

``` bash
brew install composer
```
    
Now lets install Laravel Valet using composer:

```
composer global require laravel/valet
valet install
```

## 3. Install Mailhog using Homebrew.
Execute the following shell command in your terminal:

```
brew install mailhog
```

Now you can access mailhog via http://127.0.0.1:8025


## 4. Register mailhog path with valet domain.

Execute the following shell commands in your terminal:

```
# Proxy over HTTP...
valet proxy mailhog http://127.0.0.1:8025
 
# Proxy over TLS + HTTP/2...
valet proxy mailhog http://127.0.0.1:8025 --secure (optional)
```

Now you can access mailhog in your favorite browser via http://mailhog.test.