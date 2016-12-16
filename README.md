# A Collection of Tools for Processing Ontologies Edit

CI: [![Build Status](https://travis-ci.org/JPL-IMCE/gov.nasa.jpl.imce.ontologies.tools.svg?branch=master)](https://travis-ci.org/JPL-IMCE/gov.nasa.jpl.imce.ontologies.tools)

Maven: [ ![Download](https://api.bintray.com/packages/jpl-imce/gov.nasa.jpl.imce/gov.nasa.jpl.imce.ontologies.tools/images/download.svg) ](https://bintray.com/jpl-imce/gov.nasa.jpl.imce/gov.nasa.jpl.imce.ontologies.tools/_latestVersion)

## Publishing a new version

### Packaging & Uploading

```shell
git tag -s -m"<version>" <version>
git push origin <version>
```

Travis-CI will execute the [scripts/travis-deploy.sh](scripts/travis-deploy.sh) script that uses SBT to:
- create a zip artifact of all the tools 
- upload this artifact to the [bintray repo](https://bintray.com/jpl-imce/gov.nasa.jpl.imce/gov.nasa.jpl.imce.ontologies.tools)

### Publishing

Use the [JFrog CLI](https://www.jfrog.com/getcli/) to publish the uploaded version:

```shell
jfrog bt vp jpl-imce/gov.nasa.jpl.imce/gov.nasa.jpl.imce.ontologies.tools/<version>
```

### Republishing a tagged version

If for some reason the uploaded version is not satisfactory or needs to be rebuild:

- Delete the uploaded and/or published version:

```shell
jfrog bt vd jpl-imce/gov.nasa.jpl.imce/gov.nasa.jpl.imce.ontologies.tools/<version>
```

- Click on "Restart build" on [Travis CI](https://travis-ci.org/JPL-IMCE/gov.nasa.jpl.imce.ontologies.tools)