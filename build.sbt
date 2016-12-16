import sbt.Keys._
import sbt._

import gov.nasa.jpl.imce.sbt._

import scala.xml.{Node => XNode}
import scala.xml.transform._

useGpg := true

lazy val artifactZipFile = taskKey[File]("Location of the zip artifact file")

lazy val root = Project("gov-nasa-jpl-imce-ontologies-tools", file("."))
  .enablePlugins(IMCEGitPlugin)
  .enablePlugins(IMCEReleasePlugin)
  .settings(IMCEReleasePlugin.packageReleaseProcessSettings: _*)
  .settings(
    IMCEKeys.licenseYearOrRange := "2009-2016",
    IMCEKeys.organizationInfo := IMCEPlugin.Organizations.omf,
    IMCEKeys.targetJDK := IMCEKeys.jdk18.value,

    projectID := {
      val previous = projectID.value
      previous.extra(
        "build.date.utc" -> buildUTCDate.value,
        "artifact.kind" -> "omf.ontologies")
    },

    // disable using the Scala version in output paths and artifacts
    crossPaths := false,

    extractArchives := {},

    artifactZipFile := {
      import com.typesafe.sbt.packager.universal._

      val top=baseDirectory.value
      val subDirs = Seq("data", "documents", "exports", "launchers", "lib", "tools")
      val fileMappings: Seq[(File, String)] =
        subDirs.foldLeft(Seq.empty[(File,String)]) { (acc, dir) =>
          val inc: Seq[(File,String)] = (top / dir ***).pair(relativeTo(top)).sortBy(_._2)
          acc ++ inc
        }

      val zipFile: File = baseDirectory.value / "target" / s"imce.ontologies.tools-${version.value}.zip"
      ZipHelper.zipNative(fileMappings, zipFile)

      zipFile
    },

    addArtifact(Artifact("imce-omf_ontologies", "zip", "zip", Some("resource"), Seq(), None, Map()), artifactZipFile),

    makePom := { artifactZipFile; makePom.value },

    sourceGenerators in Compile := Seq(),

    managedSources in Compile := Seq(),

    // disable publishing the main jar produced by `package`
    publishArtifact in(Compile, packageBin) := false,

    // disable publishing the main API jar
    publishArtifact in(Compile, packageDoc) := false,

    // disable publishing the main sources jar
    publishArtifact in(Compile, packageSrc) := false,

    // disable publishing the jar produced by `test:package`
    publishArtifact in(Test, packageBin) := false,

    // disable publishing the test API jar
    publishArtifact in(Test, packageDoc) := false,

    // disable publishing the test sources jar
    publishArtifact in(Test, packageSrc) := false
  )


def UpdateProperties(base: File): RewriteRule = {

  val targetDir = base / "target"
  val oDir= targetDir / "ontologies"
  val fileMappings = (oDir.*** pair relativeTo(targetDir)).sortBy(_._2)
  val oFiles = fileMappings flatMap {
    case (file, path) if ! file.isDirectory =>
      Some(MD5File(name=path, md5=MD5.hashFile(file)))
    case _ =>
      None
  }
  val all = MD5SubDirectory(
    name = "ontologies",
    files = oFiles)

  new RewriteRule {

    import spray.json._
    import MD5JsonProtocol._

    override def transform(n: XNode): Seq[XNode]
    = n match {
      case <properties>{props@_*}</properties> =>
        <properties>{props}<md5>{all.toJson}</md5></properties>
      case _ =>
        n
    }
  }
}