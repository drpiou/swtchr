# swtchr
This script allows you the run different version of bin in specific folders.



## Motivation

Dealing with PHP versions can be painful if you have many different projects which requires each a specific version of PHP to run with Composer. There is a `platform` option in the `composer.json`, but it doesn't cover PHP versions range.

I wanted a final, clean solution, which alows me to copy/paste cli like `composer require <package>` instead of an alias like `composer72 require <package>` to run PHP 7.2.

In my case, I also want to "sync" the version executed by php and composer, for example with Laravel and its artisan command. I were in a situation where `php artisan` was running PHP 7.2 because of the alias created by my MAMP, while `composer` was running PHP 7.1 because of my OS X `/usr/bin/php`, into the same root project.

This is also my very first batch script. The code can highly be optimized, but it works with my intial tests, and I must say, it will saves me a lot of pain, and I'm glad if it helps you :)



## Installation

Copy script:

```bash
mv swtchr.sh /usr/local/bin/swtchr
```

Make it executable:

```bash
chmod u+x /usr/local/bin/swtchr
```

Done!



## Usage

```
switchr <command>
    <command>   The command to execute (eg: 'composer require laravel/laravel')
    -l          The bin platform (optional - used for config file override)
    -p          The bin path (required)
    -f          The bin binaries folder (optional - default to '/')
    -b          The bin to execute (required)
    -k          The fallback bin to execute if no version found (optional)
    -s          The version to find (optional - Semantic Versioning)
    -d          Debug the selected bin path
    -v          Debug (verbose) the selected bin path
    -h          Print help
```



With OS X binary, it should looks like something similar to:

```bash
swtchr test.php -p /usr/bin -b php

<same as>

php test.php
```



With MAMP binaries, it should looks like something similar to:

```bash
swtchr test.php -p /Applications/MAMP/bin/php -f /bin -b php -s "~7.2.0"
```



## Configuration

To make it completly transparent, and to define a default platform-specific version, you can add a configuration file under the user folder located at `~/.swtchr`:

```
default.debug=      // If "1", swtchr will debug the selected bin path
default.verbose=    // If "1", swtchr will debug verbose the selected bin path

{-l}.path=          // The main folder where to look at "versioned" folder (eg: php7.2.21)
{-l}.folder=        // The folder where to look for a {bin} under the "versioned" folder
{-l}.bin=php        // The bin to find
{-l}.fallback=      // If no versioned/bin found, the default bin absolute path
{-l}.version=       // The semantic version to match (eg: ~7.2.0)
{-l}.debug=         // If "1", swtchr will debug the platform selected bin path
{-l}.verbose=       // If "1", swtchr will debug verbose the platform selected bin path
```



To silently switch the bin versions for each project you may have, you can also add the same configuration file under each project folder that will override the user one, named as `.swtchr`.



## Use Case

So now, let's say we have two Laravel projects and we are using MAMP.

We would first start to configure `~/.swtchr`:

```
default.debug=
default.verbose=

php.path=/Applications/MAMP/bin/php
php.folder=/bin
php.bin=php
php.fallback=/usr/bin/php
php.version=~7.2.0
php.debug=
php.verbose=
```



To call `php` or `composer` with `swtchr`, we can add into `~/.bash_profile`:

```bash
phpswtchr() { swtchr "$*" -l php -d; }

alias php="phpswtchr"
alias composer="phpswtchr /usr/local/bin/composer"
```



Then, in the `projectA`, everytime we do the following:

```bash
php artisan route:list
```

Or

```bash
composer require laravel/laravel
```

The PHP version used would be *7.2.21*.



Then, in the `projectB`, we would add a file `.swtchr`:

```
php.version=~7.1.0
```

And now, everytime we do the following in this project:

```bash
php artisan route:list
```

Or

```bash
composer require laravel/laravel
```

The PHP version used would be *7.1.31*.

