* **v0.4.2** Updated base Java Dockerfile to Grade 3, and removed compilation during build - instead uses shared folder and gradle run. Added manage and devenv-help aliases. Updated logstash config to better cope with multiple line traces. Added LOG_LEVEL into base python Dockerfile to support latest skeleton.
* **v0.4.1** Updated Logstash config and Kibana saved searches to use new JSON log format.
* **v0.4.0** Added ELK stack support (#2) - see the [Logging section](#logging) for instructions. Reworked base Dockerfiles for increased efficiency and support for skeleton unit test structure. More aliases added, and tab-complete enabled for all aliases.
* **v0.3.1** Many optimisations and fixes (#16, #18)
* **v0.3.0** Added app-specific commodity provision tracking (#1). Fixed long line character overwriting issues in windows during SSH. Added aliases for common commands (#14).
* **v0.2.6** *BREAKING CHANGE* - Removed default CMD and SETTINGS env vars from base python/flask Dockerfiles. Apps must implement these themselves (although SETTINGS is not used in the current app structure).
* **v0.2.5** Updates for split app/alembic DB users (#11) and increased reload reliability.
* **v0.2.4** Fixed fatal error when doing a `vagrant reload` (#13)
* **v0.2.3** Fixed docker errors during vagrant up when no (docker) applications are specified in the configuration (#12)
* **v0.2.2** Updated base container centos versions, updated gradle version in java box. Fixed #10.
* **v0.2.1** Updated base vagrant box version, fixed a few provisioning bugs
* **v0.2** First public release