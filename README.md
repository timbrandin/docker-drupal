Drupal development with Docker
==============================

[![](https://badge.imagelayers.io/timbrandin/drupal.svg)](https://imagelayers.io/?images=timbrandin/drupal:latest 'Get your own badge on imagelayers.io')

Quick and easy to use Docker container for your *local Drupal development*. It contains a LAMP stack and an SSH server, along with an up to date version of Drush. It is based on [Ubuntu Trusty](https://wiki.debian.org/DebianWheezy).

Getting started
-------

**OSX/Windows**: Use [Kitematic](https://kitematic.com/) and search and download `timbrandin/drupal`

**Linux**: Follow the guide on running it below.


Summary
-------

This image contains:

* Apache 2.4.7
* MySQL 5.5.44-0ubuntu0.12.04.1
* PHP 5.6.11-1+deb.sury.org~trusty+1
* Drush 7.0
* Drupal 7.38
* Composer

### Passwords

* MySQL: `root:` (no password)
* SSH: `root:root`

### Exposed ports

* 80 (Apache)
* 22 (SSH)
* 3306 (MySQL)

Installation
------------

### Github

Clone the repository locally and build it:

	git clone https://github.com/timbrandin/docker-drupal.git
	cd docker-drupal
	docker build -t yourname/drupal .

### Docker repository

Get the image:

	docker pull timbrandin/drupal

Running it
----------

```
docker run -d -P --name drupal -t timbrandin/drupal
```

> Notice! We're automounting the exposed ports with `-P`.

Here's an example running the container and forwarding `localhost:8080` to the container, (notice on OSX it will be your virtual machine's IP instead of localhost):

```
docker run -d -p 8080:80 --name drupal -t timbrandin/drupal
```

### Writing code locally

Here's an example running the container, forwarding port `8080` like before, but also mounting the containers web folder `var/www/` to my local `web/` folder with Drupal. I can then start writing code on my local machine, directly in this folder, and it will be available inside the container:

```
docker run -d -p 8080:80 --name drupal -v `pwd`/web:/var/www/ -t timbrandin/drupal
```

### Using Drush

Open a terminal to your Docker container:
```
docker exec -it drupal /bin/bash
```

Run Drush commands like these on your site.
```
drush pm-update
```


