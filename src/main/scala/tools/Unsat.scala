import org.semanticweb.owlapi.apibinding.OWLManager
import com.clarkparsia.pellet.owlapiv3.{PelletReasoner, PelletReasonerFactory}
import com.clarkparsia.owlapi.explanation.GlassBoxExplanation
import org.semanticweb.owlapi.io.OWLFunctionalSyntaxOntologyFormat
import org.semanticweb.owlapi.io.StringDocumentTarget
import org.semanticweb.owlapi.model.{IRI, OWLClass, OWLOntology}
import org.semanticweb.owlapi.vocab.PrefixOWLOntologyFormat
import uk.ac.manchester.cs.owl.owlapi.OWLOntologyIRIMapperImpl

import scala.io.Source
import scala.compat.java8.FunctionConverters._
import scala.collection.JavaConversions.{asScalaSet, iterableAsScalaIterable, _}

/**
  * Usage: <modules file> <resource dir> <iri prefix file>
  *   where:
  *   <modules file> is a text file of ontology IRIs to load
  *   <resource dir> is the root folder for the ontology IRIs (mapped via a catalog)
  *   <iri prefix file> is a text file where each line is either:
  *    - a comment, starting with //
  *    - an IRI prefix
  *
  *   After loading all ontologies, find all classes whose IRI begin with one
  *   of the IRI prefixes loaded from <iri prefix file> and check for unsatisfiability.
  */
object Unsat {

  def main(argv: Array[String]): Unit = {

    val mapper = new OWLOntologyIRIMapperImpl()

    val modulesFile = new java.io.File(argv(0))
    if (!modulesFile.exists() || !modulesFile.canRead)
      throw new IllegalArgumentException(s"Cannot read modules file: $modulesFile")

    val resourcesDir = new java.io.File(argv(1))
    if (!resourcesDir.exists || !resourcesDir.isDirectory || !resourcesDir.canExecute)
      throw new IllegalArgumentException(s"Cannot read resources folder: $resourcesDir")

    val classIRIsFile = new java.io.File(argv(2))
    if (!classIRIsFile.exists || !classIRIsFile.canRead)
      throw new IllegalArgumentException(s"Cannot read Class IRI file: $classIRIsFile")

    val iriPrefixes = Source.fromFile(classIRIsFile).getLines().flatMap { line =>
      if (!line.startsWith("//"))
        Some(IRI.create(line).toString)
      else
        None
    }.to[Set]

    val iriMap = Source.fromFile(modulesFile).getLines().flatMap { moduleIRI =>
      val moduleRelPath = moduleIRI.stripPrefix("http://") + ".owl"
      val moduleFile = resourcesDir.toPath.resolve(moduleRelPath).toFile
      if (!moduleFile.exists() || !moduleFile.canRead) {
        System.out.println(s"Cannot read module file: $moduleFile")
        None
      } else {
        val ontologyIRI = IRI.create(moduleIRI)
        val documentIRI = IRI.create(moduleFile)
        mapper.addMapping(ontologyIRI, documentIRI)
        Some(ontologyIRI -> documentIRI)
      }
    }.toMap

    System.out.println(s"Read ${iriMap.size} mappings.")

    val om = OWLManager.createOWLOntologyManager()
    om.addIRIMapper(mapper)

    val format = new OWLFunctionalSyntaxOntologyFormat()

    val collection_ontology = om.createOntology()

    val addAxioms = (o: OWLOntology) => {
      om.addAxioms(collection_ontology, o.getAxioms)
      ()
    }
    val consumer: java.util.function.Consumer[_ >: OWLOntology] = asJavaConsumer(addAxioms)

    iriMap.foreach {
      case (ontologyIRI, documentIRI) =>
        val ont = Option.apply(om.getOntology(ontologyIRI)) match {
          case None =>
//            System.out.println(s"# Loading IRI: $documentIRI")
            val ont = om.loadOntologyFromOntologyDocument(documentIRI)
            val axs = ont.getAxiomCount
            val cls = ont.getClassesInSignature()
//            System.out.println(s" => $axs axioms and ${cls.size} classes")
            ont
          case Some(ont) =>
//            System.out.println(s"#  Loaded IRI: $documentIRI")
            val axs = ont.getAxiomCount
            val cls = ont.getClassesInSignature()
//            System.out.println(s" => $axs axioms and ${cls.size} classes")
            ont
        }
        om.getImportsClosure(ont).forEach(consumer)
        Option.apply(om.getOntologyFormat(ont))
          .collectFirst { case pf: PrefixOWLOntologyFormat => pf }
          .foreach(format.copyPrefixesFrom)

    }

    val df = om.getOWLDataFactory
    val owl_nothing = df.getOWLNothing

    val reasoner: PelletReasoner = PelletReasonerFactory.getInstance().createReasoner(collection_ontology)
    val gb_explanation = new GlassBoxExplanation(reasoner)

    val classes = collection_ontology.getClassesInSignature.to[Set]
    System.out.println(s"Collection ontology has: ${classes.size} classes")

    val subset: Set[OWLClass] = classes.filter { cls =>
      val iri = cls.getIRI.toString
      iriPrefixes.exists(iri.startsWith)
    }
    System.out.println(s"${subset.size} classes have IRIs starting with one of the ${iriPrefixes.size} IRI prefixes")

    reasoner.refresh()

    val unsat: Set[OWLClass] = subset.flatMap { cls =>
      System.out.println(s"Satisfiability: ${cls.getIRI}")
      if (reasoner.isSatisfiable(cls)) {
        System.out.println(s" => SAT!")
        None
      } else {
        System.out.println(s" => UNSAT!")
        val axioms = gb_explanation.getExplanation(cls)
        val ont = om.createOntology(axioms)
        val target = new StringDocumentTarget()
        om.saveOntology(ont, format, target)
        System.out.println("========================================")
        System.out.println(target.toString)
        System.out.println("========================================")
        Some(cls)
      }
    }

    if (unsat.isEmpty) {
      System.out.println(s"No unsatisfiable classes found in the ${subset.size} subset of all ${classes.size} classes!")
      val result = (reasoner.getUnsatisfiableClasses.to[Set] - owl_nothing).to[Vector].sortBy(_.getIRI.toString)
      if (result.isEmpty) {
        System.out.println(s"*** No unsatisfiable classes among all of all ${classes.size} classes!")
      } else {
        System.out.println(s"*** ${result.size} unsatisfiable classes among all of all ${classes.size} classes!")
        result.foreach(u => System.out.println(u.getIRI.toString))
      }
    } else {
      System.out.println(s"Found ${unsat.size} unsatisfiable classes in the ${subset.size} subset of all ${classes.size} classes!")

    }

  }
}
