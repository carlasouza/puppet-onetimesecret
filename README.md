# onetimesecret

[One-Time Secret](http://onetimesecret.com) is a small webapp to share sensitive data with a link that can be viewed only one time.

## Usage

Include this class on your node to have One-Time Secret running with default configuration

    include onetimesecret

## Limitations

The application generates a link that uses a preconfigured domain and port. Right now it is only generating using `localhost:80`.
Tested on Ubuntu 14.04 only.

## Development

This is a work in progress. The way it is right now will install One-Time Secret with default configuration and passwords.

The roadmap includes:

* Support Debian;
* Redirect logs to the right place;
* Choose between rvm or system's ruby instalation;
* Add one redis module as dependency (maybe?);
* Properly management of config files;
* Delete temp download file after installation;
* Extract params to `params.pp` class.
