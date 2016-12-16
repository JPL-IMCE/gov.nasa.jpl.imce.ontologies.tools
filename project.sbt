
sbtPlugin := false

name := "gov.nasa.jpl.imce.ontologies.tools"

description := "Tools for JPL's Ontological Modeling Framework vocabularies for Integrated Model-Centric Engineering (IMCE)"

moduleName := name.value

organization := "gov.nasa.jpl.imce"

organizationName := "JPL-IMCE"

homepage := Some(url(s"https://github.jpl.nasa.gov/imce/${moduleName.value}"))

organizationHomepage := Some(url("https://github.jpl.nasa.gov/imce"))

git.remoteRepo := "git@github.jpl.nasa.gov/imce/gov.nasa.jpl.imce.ontologies.tools.git"

scmInfo := Some(ScmInfo(
  browseUrl = url(s"https://github.jpl.nasa.gov/imce/gov.nasa.jpl.imce.ontologies.tools"),
  connection = "scm:"+git.remoteRepo.value))

developers := List(
  Developer(
    id="sjenkins",
    name="Steven S. Jenkins",
    email="steven.s.jenkins@jpl.nasa.gov",
    url=url("https://gateway.jpl.nasa.gov/personal/sjenkins/default.aspx")),
  Developer(
    id="rouquett",
    name="Nicolas F. Rouquette",
    email="nicolas.f.rouquette@jpl.nasa.gov",
    url=url("https://gateway.jpl.nasa.gov/personal/rouquett/default.aspx")))

