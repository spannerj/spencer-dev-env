# Changelog

## v1.3.2

* Changed Python from a custom LR build to IUS Community Project in all Python base images. We did not create a version 3 as it is important to catch (unlikely) compatibility issues now rather than when your apps hit Integration
* Updated Gradle to 3.3 in base Java image

## v1.3.1

* In future you will be asked if you want to apply a dev-env update. If you decline, you will not be asked again until the next day.

## v1.3.0

* You will now be prompted to remove the docker persistent storage file during vagrant destroy. This is optional (for now)
* Docker-compose updated to 1.9.0 for new machines
* ADFS certificate is now dynamically loaded from a Gitlab snippet
* ELK stack updated to v5.1.1

## v1.2.1

* Pin version of vagrant-persistent-storage plugin to fix IDE controller bug
* Fixed db2 alias
* Increased visibility of not-master-branch warning
* Base java dockerfile updated to Gradle 3.2.1
* Changed `acceptance-tests` alias to take in a parameter specifying the container name. All other parameters are passed through to the run_tests.sh script. This is so the skeleton version of that script can in turn pass them on to cucumber. Also added an identical, shorter `acctest` alias.
* Created a v2 of base python and base flask dockerfiles. Changes are the removal of the deprecated FLASK_LOG_LEVEL env var and the removal of the LC_ALL env var. Be aware when migrating your apps that this will break installation of httpretty.

## v1.2.0

* Updated Ruby/gems/bundler versions in base ruby dockerfile
* Test fix for guest clock getting out of sync when host sleeps
* Fix occasional HDD error on halt
* Pinned gunicorn and eventlet versions in base flask dockerfile
* Updated Gradle to v3.2 in base java dockerfile
* Updated ELK stack to v5.0

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
