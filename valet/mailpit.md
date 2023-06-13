# Setup [Mailpit](https://github.com/axllent/mailpit) with Laravel Valet
This article will show step by step on how to setup mailpit with Laravel Valet:
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

## 3. Install Mailpit using Homebrew.
Execute the following shell command in your terminal:

```
brew tap axllent/apps
brew install mailpit
brew services start mailpit
```

Now you can access mailpit via http://127.0.0.1:8025


## 4. Register mailpit path with valet domain.

Execute the following shell commands in your terminal:

```
# Proxy over HTTP...
valet proxy mailpit http://127.0.0.1:8025
 
# Proxy over TLS + HTTP/2...
valet proxy mailpit http://127.0.0.1:8025 --secure (optional)
```

Now you can access mailpit in your favorite browser via http://mailpit.test.

## Laravel Env

```env
MAIL_MAILER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```