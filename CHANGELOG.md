# Changelog

## v1.1.5

* Only check plugins on up, not reload. Should fix intermittent error.
* Added alias for alembic db commands, ensuring the right environment variables are set for you (assuming skeleton compliance). Example usage: alembic container-name migrate

## v1.1.4

* Added TEMPLATES_AUTO_RELOAD environment variable to base Flask Dockerfile. Can be read into a variable of the same name in config.py to disable flask caching of jinja html templates during development.

## v1.1.3

* Added ADFS public cert (for validating JWTs provided during authentication)
* Minor cosmetic improvements

## v1.1.2

* Added PostGIS extension to Postgres. See the README for usage instructions.
* Fixed nginx forgetting all custom config on container recreation

## v1.1.1

* Added nginx as a supported commodity. See the README for usage instructions.

## v1.1.0

* All the base images now rebuild on every vagrant up (#25). The current base images have been tagged as version 1, which apps can now reference to lock themselves in.
* Auto update functionality has been added.
* The base Flask dockerfile has a new env var set in order to disable sendfile support in gunicorn.
* Gradle in the base Java dockerfile has been upgraded from 3.0 to 3.1.
* If multiple ports are specified in a docker-compose-fragment, they will all be forwarded outside of vagrant. Previously only the first one was.
* Minor bug fixes (#27 and #28).

## v1.0.0

* Added db2 and psql aliases.
* Altered test aliases to use new Makefile commands (see skeleton app).
* Fixed tab-complete on rebuild and remove aliases.
* Fixed DB2 init SQL running while DB2 was still starting up.
* Made vagrant up fail if building any of the Docker images fail.
* Moved the (deprecated) FLASK_LOG_LEVEL env var from base Python image to base Flask image.
* Updated base Ruby image to have phantomjs.
* Removed Ruby installation from core vagrant machine. It should now be possible to dockerise an acceptance-tests repo and run the tests inside it.

## v0.4.2

* Updated base Java Dockerfile to Grade 3, and removed compilation during build - instead uses shared folder and gradle run.
* Added manage and devenv-help aliases.
* Updated logstash config to better cope with multiple line traces.
* Added LOG_LEVEL into base python Dockerfile to support latest skeleton.

## v0.4.1

* Updated Logstash config and Kibana saved searches to use new JSON log format.

## v0.4.0

* Added ELK stack support (#2) - see the [Logging section](#logging) for instructions.
* Reworked base Dockerfiles for increased efficiency and support for skeleton unit test structure.
* More aliases added, and tab-complete enabled for all aliases.

## v0.3.1

* Many optimisations and fixes (#16, #18)

## v0.3.0

* Added app-specific commodity provision tracking (#1).
* Fixed long line character overwriting issues in windows during SSH.
* Added aliases for common commands (#14).

## v0.2.6

* *BREAKING CHANGE* - Removed default CMD and SETTINGS env vars from base python/flask Dockerfiles. Apps must implement these themselves (although SETTINGS is not used in the current app structure).

## v0.2.5

* Updates for split app/alembic DB users (#11) and increased reload reliability.

## v0.2.4

* Fixed fatal error when doing a `vagrant reload` (#13)

## v0.2.3

* Fixed docker errors during vagrant up when no (docker) applications are specified in the configuration (#12)

## v0.2.2

* Updated base container centos versions, updated gradle version in java box. Fixed #10.

## v0.2.1

* Updated base vagrant box version, fixed a few provisioning bugs

## v0.2

* First public release
