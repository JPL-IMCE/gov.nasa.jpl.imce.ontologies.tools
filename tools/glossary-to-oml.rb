require 'java'

LIBS = %w{
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//aopalliance/aopalliance/1.0/235ba8b489512805ac13a8f9ea77a1ca5ebe3e8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//aopalliance/aopalliance/1.0/4a4b6d692e17846a9f3da036438a7ac491d3c814
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//asm/asm/3.1/2eaa4de56203f433f287a6df5885ef9ad3c5bcae
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//asm/asm/3.1/c157def142714c544bdea2e6144645702adf7097
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.beust/jcommander/1.72/6375e521c1e11d6563d4f25a07ce124ccf8cd171
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.beust/jcommander/1.72/7ef123d5dfb6f839b41265648ff1be34982d50f8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.beust/jcommander/1.72/b04f3ee8f5e43fa3b162981b50bb72fe1acabb33
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-annotations/2.9.0/7c10d545325e3a6e72e06381afe469fd40eb701
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-annotations/2.9.0/9978adad2c78154ca4aca7cd2a71941e1278f724
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-annotations/2.9.0/a0ad4e203304ccab7e01266fa814115850edb8a9
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-core/2.9.8/acc65b3b6e07784dc1760fa4e460238eb2a9073a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-core/2.9.8/ecaea301e166a0b48f11615864246de739b6619b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-core/2.9.8/f5a654e4675769c716e5b387830d19b501ca191
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-databind/2.9.8/11283f21cc480aa86c4df7a0a3243ec508372ed2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-databind/2.9.8/a1dea243882227fc27c350a5b25ca76ef4ecb7d7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.jackson.core/jackson-databind/2.9.8/f66792d499a6fea6c7a743558f940e0ebf775ce3
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.uuid/java-uuid-generator/3.1.5/45fc02706492997d8889349cc7de7813aebc8802
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.uuid/java-uuid-generator/3.1.5/8784df945176ab4e8e268fd24508cf882d3378de
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.fasterxml.uuid/java-uuid-generator/3.1.5/d3ee157cb8bc7a789458426cef6dcf17b5b6655d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.code.findbugs/jsr305/1.3.9/40719ea6961c0cb6afaeb6a921eaa1f6afd4cfdf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.code.findbugs/jsr305/3.0.2/25ea2e8b0c338a877313bd4672d3fe056ea78f0d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.code.findbugs/jsr305/3.0.2/7cb5b4e91eb0741882c8fefb2fd0338eff9857c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.code.findbugs/jsr305/3.0.2/b19b5927c2c25b6c70f093767041e641ae0b1b35
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.1.3/28ea6f81741992c53c5f8030995604345606dd9d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.1.3/39b109f2cd352b2d71b52a3b5a1a9850e1dc304b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.1.3/990fe1fd48078a2befecdfcebcad8e6e1bd195a0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.2.0/88e3c593e9b3586e1c6177f89267da6fc6986f0c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.2.0/959f406f238a0e047ed2a227479ff9db28173be9
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.errorprone/error_prone_annotations/2.2.0/a8cd7823aa1dcd2fd6677c0c5988fdde9d1fb0a3
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/failureaccess/1.0.1/1d064e61aad6c51cc77f9b59dc2cccc78e792f5a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/failureaccess/1.0.1/1dcf1de382a0bf95a3d8b0849546c88bac1292c9
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/failureaccess/1.0.1/a9aadb2d577ff54ba3115ee7357cbe65bd2a470f
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/18.0/418be347c254422b51adee3cacb10e3f69e279ec
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/18.0/ad97fe8faaf01a3d3faacecd58e8fa6e78a973ca
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/18.0/cce0823396aa693798f8882e64213b1772032b09
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/21.0/3a3d111be1be1b745edfa7d91678a12d7ed38709
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/21.0/7d48c9b5304b8bab31d1ed7c9ef9670b646866c0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/21.0/b9ed26b8c23fe7cd3e6b463b34e54e5c6d9536d5
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/23.4-android/6b52ce80a01cdd1bda08d81d2e4035e5399ee903
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/23.4-android/ae2ca67cf7b1a5347eff75fc23a6d1694a8663d4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/23.4-android/ee51f32f12fa72eb875bc947a71420e46ae13954
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/27.0.1-jre/7515204e130bb73fea9f6df11e58559e6be2dcf0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/27.0.1-jre/bd41a290787b5301e63929676d792c507bbc00ae
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/guava/27.0.1-jre/cb5c1119df8d41a428013289b193eba3ccaf5f60
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.guava/listenablefuture/9999.0-empty-to-avoid-conflict-with-guava/b421526c5f297295adef1c886e5246c39d4ac629
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.inject/guice/3.0/9785ebd9ca29e8bcac23a2e6ce9ea3ccb339fe18
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.inject/guice/3.0/9d84f15fe35e2c716a02979fb62f50a29f38aefa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.inject/guice/3.0/d117c4481f64955cb1862ed38cb568add2f5fe05
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.j2objc/j2objc-annotations/1.1/2e1e0c8db5be95ec85d19d456186f8989ea263fa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.j2objc/j2objc-annotations/1.1/976d8d30bebc251db406f2bdb3eb01962b5685b3
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.j2objc/j2objc-annotations/1.1/dcd31de68a90e41e336f6b7afce0d39285c433d7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.truth/truth/0.40/d74e716afec045cc4a178dbbfde2a8314ae5574
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.truth/truth/0.40/eb5b4f556cd0ae2a2afefb3ef2c9a8167692d0da
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.google.truth/truth/0.40/fac83d0d969bb1250dc02b5947b19801a8a8b910
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.googlecode.java-diff-utils/diffutils/1.3.0/649b2d7051029a67cd1b36124c4ff8138e202b4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.googlecode.java-diff-utils/diffutils/1.3.0/7e060dd5b19431e6d198e91ff670644372f60fbd
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.googlecode.java-diff-utils/diffutils/1.3.0/90b4aaa9530827fe6ad2b6684389c86999e861a3
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.thoughtworks.xstream/xstream/1.4.10/23b668e17d1e558df7564dbb4ac19f6a3b241e5c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.thoughtworks.xstream/xstream/1.4.10/24b0de5fa33b368f5fe8f9eb5242343bb39d3abb
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.thoughtworks.xstream/xstream/1.4.10/dfecae23647abc9d9fd0416629a4213a3882b101
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.typesafe.sbt/compiler-interface/0.13.15/bad996ed4fc3e83b872525e9cd7b80d81b98a324
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.typesafe.sbt/incremental-compiler/0.13.15/95e20d00b25a7aae19838009c11578b7e6b258ad
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.typesafe.sbt/sbt-interface/0.13.15/93fe450d5f5efb111397a34bc1fba0d50368a265
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//com.typesafe.zinc/zinc/0.3.15/12e1f782684f2702e847faa0994eed4711270687
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-codec/commons-codec/1.8/af3be3f74d25fc5163b54f56a0d394b462dafafd
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-codec/commons-codec/1.8/ea7b97bfc46dc4b28bc53af3e530199a657933bf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-codec/commons-codec/1.8/ea9dcc7afadc181c9d7b9492516036693888d468
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.2/83b5b8a7ba1c08f9e8c8ff2373724e33d3c1e22a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.2/8d6b98f21262995489a8418fff8da992d7e25c1e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.2/92da9b7269652c310afc2a2458e72e5a1aa4a54a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.6/2566800dc841d9d2c5a0d34d807e45d4107dbbdf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.6/38ce4d06c1917fa2f2b1dde31bd111223ac7a551
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-io/commons-io/2.6/815893df5f31da2ece4040fe0a12fd44b577afaf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-lang/commons-lang/2.4/16313e02a793435009f1e458fa4af5d879f6fb11
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-lang/commons-lang/2.4/2b8c4b3035e45520ef42033e823c7d33e4b4402c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-lang/commons-lang/2.4/bb93922b0796902b3683fa38e554b2d2c75c8a34
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-logging/commons-logging/1.2/4bfc12adfe4842bf07b657f0369c4cb522955686
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-logging/commons-logging/1.2/83033ee697035dfb9ce3503e1ac0c5a33021e503
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//commons-logging/commons-logging/1.2/ecf26c7507d67782a3bbd148d170b31dfad001aa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.caesar/gov.nasa.jpl.imce.caesar.efse/1.11.0/3bf5109b61f7fdb69f751cef5f85ff6a60ac891a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.caesar/gov.nasa.jpl.imce.caesar.efse/1.13.0/f5ad3e7ea0892d9935133b6a559ec176ac841da1
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.caesar/gov.nasa.jpl.imce.caesar.efse/1.14.0/a754a954072291d8662797d207b3aa2a2883001
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.oml/gov.nasa.jpl.imce.oml.dsl/0.9.7.4/4b78bcc6685a1d6124b419e3799c587c5351d5b7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.oml/gov.nasa.jpl.imce.oml.model.edit/0.9.7.4/ed7c68447c04d2e6f1b08dd8eb9267916a538b73
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.oml/gov.nasa.jpl.imce.oml.model/0.9.7.4/7dcf6294c69c272bac8ec7540135b432457ec389
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//gov.nasa.jpl.imce.oml/gov.nasa.jpl.imce.oml.zip/0.9.7.4/4bcdc0044fbc72cae52d8e0afe8bdde180b1c8c8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//javax.inject/javax.inject/1/6975da39a7040257bd51d21a231b76c915872d38
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//javax.inject/javax.inject/1/70ec961c25111ed9015d1af77772d96383c2d238
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//javax.inject/javax.inject/1/a00123f261762a7c5e0ec916a2c7c8298d29c400
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//junit/junit/4.12/2973d150c0dc1fefe998f834810d68f278ea58ec
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//junit/junit/4.12/941a8be4506c65f0a9001c08812fb7da1e505e21
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//junit/junit/4.12/a6c32b40bf3d76eca54e3c601e5d1470c86fcdfa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//log4j/log4j/1.2.16/78aa1cbf0fa3b259abdc7d87f9f6788d785aac2a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//log4j/log4j/1.2.16/7999a63bfccbc7c247a9aea10d83d4272bd492c6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//log4j/log4j/1.2.16/bf945d1dc995be7fe64923625f842fbb6bf443be
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.antlr/antlr-runtime/3.2/31c746001016c6226bd7356c9f87a6a084ce3715
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.antlr/antlr-runtime/3.2/fc08e5ebbee6d8c4576b34743aec39989e9bf2c4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.16.1/78a929afa216299bb47b9021909bb70f6c260bb2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.16.1/7b5cdabadb4cf12f5ee0f801399e70635583193f
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.16.1/f7dde5c5163ac128750fc2d6ec00ae6a7ff624ab
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.18/1191f9f2bc0c47a8cce69193feb1ff0a8bcb37d5
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.18/31d77fd62a1d5db4c6dd1598f2e36d0d9ee6fcda
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.commons/commons-compress/1.18/a25b942b99fde2cc2913ab39ad34abc0df4f5eb9
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpclient/4.5.2/733db77aa8d9b2d68015189df76ab06304406e50
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpclient/4.5.2/b9f9e3e5255b6ddc3bf21be05428c7a60d00e042
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpclient/4.5.2/cde431ba6b9871fbd0abb65d740424c8e5b734b6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpcore/4.4.5/440af37e216dd89769e46e90debe35f38488bfe6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpcore/4.4.5/542498265bc5a238dcb0275172b8070bd51e30af
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.httpcomponents/httpcore/4.4.5/e7501a1b34325abb00d17dde96150604a0658b54
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.ivy/ivy/2.2.0/312527950ad0e8fbab37228fbed3bf41a6fe0a1
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.ivy/ivy/2.2.0/dad960d784bb954e2c732ea9cba791f6e5819310
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.apache.ivy/ivy/2.2.0/f9d1e83e82fc085093510f7d2e77d81d52bc2081
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.checkerframework/checker-qual/2.5.2/bfab5d13a888ce75ba0104fdb310808e445ff67d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.checkerframework/checker-qual/2.5.2/cea74543d5904a30861a61b4643a5f2bb372efc4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.checkerframework/checker-qual/2.5.2/ebb8ebccd42218434674f3e1d9022c13df1c19f8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.14/775b7e22fb10026eed3f86e8dc556dfafe35f2d5
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.14/886474da3f761d39fcbb723d97ecc5089e731f42
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.14/d90e19c7bc3a594aac2307bcfe9f2362ec4108ea
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.17/8fb5b5ad9c9723951b9fccaba5bb657fa6064868
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.17/c67d33bf1588c89f633cf6b5a629d0e1dc1b02c4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.codehaus.mojo/animal-sniffer-annotations/1.17/f97ce6decaea32b36101e37979f8b647f00681fb
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.birt.runtime.3_7_1/org.apache.xml.resolver/1.2.0/7c9c22053b04772e81dc62d665b202eeae82ae47
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore.xtext/1.2.0/3e894c4874ec8bee8f5b069aaa8641244ea31c3a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore.xtext/1.2.0/7bf74b688343e7f18af551fd4c6f3b87d574ffc
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore.xtext/1.2.0/dd86c019629ac98fcff5d25307382397c28d9d92
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore/2.12.0/269af699ee128e5d75563f00546e654b1b610539
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore/2.12.0/5ba8598688ee6c5c2cdc0539560313f8fe196259
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen.ecore/2.12.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen/2.11.0/b9f534339675a5205857f17153f5b01f690ac567
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen/2.11.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.codegen/2.11.0/fc79590ac6de1f24c79f7b133d304831776c998b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.common/2.12.0/af459a19ba693bf5adc846a38636e60360e84963
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.common/2.12.0/ce79e5cc3c2de3e8d96a6df4dad3bf5c9fa6b7d7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.common/2.12.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.change/2.11.0/3e240518c1b7df8a42acb5d54121693128aaa54e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.change/2.11.0/73516dc035e73915446b1bd9fd404ceb83456818
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.change/2.11.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore.lib/1.1.100/32aab3e43ff4e5f0fe61c451b457571ff1df39d8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore.lib/1.1.100/a7d6872f03d380969c5ad479811806532730a8b2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore.lib/1.1.100/c6a2c9be38adaeb253bfd5f39ca69b6a9962dd7d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore/1.3.1/123a99fcd7a4cb9d454af51176810e4a30b6a211
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore/1.3.1/a38216f3d44b1c94d1df24f4bb193e8659edb532
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xcore/1.3.1/afdccb7e248faf6bd35efd240a60fbe3f1092bda
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xmi/2.12.0/ad136ea23fcdaebec17ec6c730dfdf74b2077c37
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xmi/2.12.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore.xmi/2.12.0/daddaf80c0d94360a70b603d4a44d1299683229c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore/2.12.0/644751074e8b448526815f9bdeda26770df2e213
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore/2.12.0/aa1cd16cf2bf412b6d55ae94e06303ae098d0d63
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.ecore/2.12.0/d51ecb975790a8ddffe6ae004cda9fe4c213689b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.mwe2.runtime/2.9.1.201705291010/cb005330080857ba5ca898cd4c4f5d164625bd48
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.emf/org.eclipse.emf.mwe2.runtime/2.9.1.201705291010/da2a11a6389d54dc1aca1308da8987dcefc802b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.contenttype/3.5.100/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.contenttype/3.5.100/5936a5e9d44c5a3e21ef28eff031a0bfe88f6600
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.contenttype/3.5.100/f1f15b11c992f7075f579afc0baf244f530bf97b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.jobs/3.8.0/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.jobs/3.8.0/953b5073468650e847d2bb7b9988b3111000811d
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.jobs/3.8.0/ea099fe32f6aff890a1cd71deae4c5660e89cbbf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.runtime/3.12.0/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.runtime/3.12.0/b89e5869ab42dc4dd9228cf85f7d784bc6ecbfb0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.core.runtime/3.12.0/d92224d0304f23a399d821ca9c804d7391ce98ef
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.app/1.3.400/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.app/1.3.400/4c01f677e982499789ffa78b628ea67693db949
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.app/1.3.400/8007299cf271548f601356293fece31396a7bdde
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.common/3.8.0/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.common/3.8.0/9a166c07468f7f10c03a9125669406baa05b80d0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.common/3.8.0/a3d16e12ae80f338ce40b83832a421405021e062
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.preferences/3.6.1/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.preferences/3.6.1/452b3d98e154f1ad0f6d02cd6b78528632c2dc38
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.preferences/3.6.1/ae83f317aa59ae84ec9ba8f2db7bf9e9714c0ce7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.registry/3.6.100/1eff6f5c4fde580f3f38261ec1f53479272b1d8c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.registry/3.6.100/35798edc4dc0b15bd38f468e86a0f2f516023f52
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.equinox.registry/3.6.100/605bf09597b2b07a026cacda112a5ac7ba58b024
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.osgi/3.11.3/160f3a6093598ff0d60c70e25e8e08ab898492ad
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.osgi/3.11.3/3095ea4b5f5252b5d7c153d02a527d384593fec4
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.platform/org.eclipse.osgi/3.11.3/f32e266f536979989dae9a7ce544ec938a67ca82
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.12.0/26a7e4e3a3be36180ed7d184191fd1217a86cce
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.12.0/c8a1f67e79418e4c8e8604873e821ee27ae40135
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.12.0/ec8d2cf29c4d7048bf35b764ec01ae41adf34eab
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.17.0/4839017a21beea5a8d3db9f8777ca4858603bcd0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.17.0/79c6cd8af6e094d7ae408ed6eecfdac8d20acda6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib.macro/2.17.0/a9f7e83dff3b2737d81d12a27097626fc987631c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.12.0/22fff9ecd43c87963ec4b0901d8d5d81d78c9101
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.12.0/2769b160f3c6f35d1145e1c0d8b12a0025f3cf93
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.12.0/965da680eb0d082c095de69bee79e1a430045b5
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.17.0/3e831852860b85cc6d194eb77a488a6f8e7a73d3
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.17.0/495525d2008b23271a4d707c92125b3428f965d2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtend/org.eclipse.xtend.lib/2.17.0/9ebdb700c502b0232804b251a3f74fb40394657c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.common.types/2.12.0/19038828b81c0aa2b896c8e6e3d14e8dc0472653
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.common.types/2.12.0/1b283a64176ff3351dc6b75cf2aec50742cad57a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.common.types/2.12.0/955097962a79a1e789f7cf40cadeba063867b009
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.ecore/2.12.0/2bdbeacb806fc40e3ca8584967a2b92dfda13141
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.ecore/2.12.0/682f3d8ebae9c704779989cee7ee1a3760b13f5a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.ecore/2.12.0/961c1d8b344a5f9512291a49b703fdcb2d506cb8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.util/2.12.0/1e97e8357714a53bcbb24a193a839500a9111e38
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.util/2.12.0/58455fc2625ab1f68b1fb766fe589236394f6bb
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.util/2.12.0/d60cf434422c552e38e32a1b6ab0bff28bdc7df8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.12.0/6b14480816113e67238e481ee7db8e7adedd454b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.12.0/6c8735719a76295da84dc452c884f6c86b82e44b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.12.0/87afb3d51e27ed0a8882042f24c6f22b9f5e5e8f
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.17.0/327f923ebf7fe5dfabd8f352408e9a7114c9e14c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.17.0/6de761480c9148f3c5e0f4013dce98ca77e2965c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase.lib/2.17.0/a7980fe656cb0f91bd7efea0f1ee164e7f5bef88
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase/2.12.0/61ad9ff82ef71b69654b9f0a88462f254fad5ee7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase/2.12.0/956ff42cd5c36b3399be0c8643472edceb4869c8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext.xbase/2.12.0/cb85236faadae367605464a5b4c58576d1be0f7e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext/2.12.0/1aa0dc168f3ec86e32dd812c7aa1be2fbe22ee20
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext/2.12.0/b2549244cbafed1e5fde39963d1455d099363309
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipse.xtext/org.eclipse.xtext/2.12.0/b35324fabba0387830b83eb82cc39e1fc515f899
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipselabs/cdo.p2/4.6.2/39754a5899321ffebdd0e6b489573d94998064df
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.eclipselabs/net4j.p2/4.6.2/b2cff707563bbfeb443f59cbfe92cbf40d2fa687
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.hamcrest/hamcrest-core/1.3/1dc37250fbc78e23a65a67fbbaf71d2e9cbc3c0b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.hamcrest/hamcrest-core/1.3/42a25dc3219429f0e5d060061f71acb49bf010a0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.hamcrest/hamcrest-core/1.3/ad09811315f1d4f5756986575b0ea16b99cd686f
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.3/35dcdf69a2b7df7c967fde3430cfc9c845fd4a43
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.3/7be34ff38959be78d75a115b9dfdcbb8a821dc4c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.3/7c0d3199ba5178241d4a96334e94092e68cba9cf
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.4/359df59a599b42cec11f6ca2b614611c089b18ae
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.4/4de69d0814b668525f0856a8fb247ba0c2f0b650
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-api/2.13.4/c100f76afb9ba9cd556d69edfe089d52b3d990d7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.3/2fc0f0d212d98f918a8e1aea025e9ccddf1db689
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.3/3f1968f284af472d90d37bf26e8de1a263c6e013
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.3/bffb77f845718415f77431ca7578637a19af53d6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.4/a2eb7671be6fd675cd98d93db578d34d2bd2e4d6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.4/a6b150ca984bbb5ae39c980e621ce6209dd98a32
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-client/2.13.4/b14719cae1144b18b9b53ac5d816b0689c4d096e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.3/38e626416e9d8787d0ca1306a4ec281e6cdda4e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.3/54d0bf8a9ab42727d357b8ed43ae1bf068aebd13
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.3/dfa6aa58bf48b858a07d2e11ff5c68ee25d5ffe2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.4/87c5c43ffcf5ccbef48a4ae034096c4dc3446fb
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.4/b33efdba975b9946f66d9b3481399c2e135497fe
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor-gradle/4.9.4/d565e84c345999d47fc4988e7a5a92c1a7df67a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.3/74cd3dfc4654ff8806fb9e012ca12d988f6403c8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.3/87067c6ff563a936f1164e83d070c153f8a86ab0
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.3/b90eea44b8254c46e9460cb27618cbb03a405a33
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.4/1bdcca83756f50a791d1aa8aa0bdfcf62a887c27
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.4/21f89f2c43c958294eb865c4cf77a070fca7f387
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.jfrog.buildinfo/build-info-extractor/2.13.4/ef7d4acda0d86fbf8dbebbf84866f5aec7a5c1be
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.objenesis/objenesis/2.6/27c490ca18fcdfb94e28387e04ae37c4aa1abb23
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.objenesis/objenesis/2.6/639033469776fd37c08358c6b92a4761feb2af4b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.objenesis/objenesis/2.6/96614f514a1031296657bf0dde452dc15e42fcb8
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-commons/5.0.1/78ebb2694324283f3120aa3ed52465b22fab8a4a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-commons/5.0.1/7b7147a390a93a14d2edfdcf3f7b0e87a0939c3e
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-commons/5.0.1/dc71b9748ba9e775fb63e5156305ab3ce5d64b53
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-tree/5.0.1/1b1e6e9d869acd704056d0a4223071a511c619e6
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-tree/5.0.1/78ebb2694324283f3120aa3ed52465b22fab8a4a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm-tree/5.0.1/dc71b9748ba9e775fb63e5156305ab3ce5d64b53
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm/5.0.1/2fd56467a018aafe6ec6a73ccba520be4a7e1565
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm/5.0.1/78ebb2694324283f3120aa3ed52465b22fab8a4a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.ow2.asm/asm/5.0.1/dc71b9748ba9e775fb63e5156305ab3ce5d64b53
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang.modules/scala-java8-compat_2.12/0.8.0/1e6f1e745bf6d3c34d1e2ab150653306069aaf34
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang.modules/scala-java8-compat_2.12/0.8.0/a33ce48278b9e3bbea8aed726e3c0abad3afadd
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang.modules/scala-java8-compat_2.12/0.8.0/ee2915a9c58bcb9822a59d14b9d91285befcacfa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang.modules/scala-xml_2.12/1.0.6/e22de3366a698a9f744106fb6dda4335838cf6a7
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-compiler/2.10.6/9b15174852f5b6bb1edbf303d5722286a0a54011
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-compiler/2.12.6/dd48b2f726613dee9399301ca007e3b93c9b2d33
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-library/2.10.6/421989aa8f95a05a4f894630aad96b8c7b828732
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-library/2.12.6/1157d5760b985d87564aed6f783034d91b5c6a45
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-library/2.12.6/137684a667c7ca9486bb5d2f5e534422b0f6f09b
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-library/2.12.6/6bd975dd5ca2a50b94413b708389b892ae423181
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-reflect/2.10.6/3259f3df0f166f017ef5b2d385445808398c316c
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.scala-lang/scala-reflect/2.12.6/f2c1ebc398963457d3b62dddde4562decb32e39a
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.sonatype.sisu.inject/cglib/2.2.1-v20090111/65030c30094de36e3fddbc22442d47cbf547741f
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.sonatype.sisu.inject/cglib/2.2.1-v20090111/7ce5e983fd0e6c78346f4c9cbfa39d83049dda2
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//org.sonatype.sisu.inject/cglib/2.2.1-v20090111/ba2665faef4ee6f4a133d9fa79311db9ed608451
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//xmlpull/xmlpull/1.1.3.1/2b8e230d2ab644e4ecaa94db7cdedbc40c805dfa
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//xpp3/xpp3_min/1.1.4c/19d4e90b43059058f6e056f794f0ea4030d60b86
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//xpp3/xpp3_min/1.1.4c/aa7f7f5da2c34374c2880ce04bd8fe32a24fc87
/Users/sjenkins/.gradle/caches/modules-2/files-2.1//xpp3/xpp3_min/1.1.4c/fffe25ec1f20ec1cfdc0edd41c6e0d55bc0dbaf5
}
LIBS.each { |l| $:.unshift(l) }

require 'gov.nasa.jpl.imce.oml.model-0.9.7.4.jar'
require 'gov.nasa.jpl.imce.oml.zip-0.9.7.4.jar'
require 'org.eclipse.emf.ecore-2.12.0.jar'
require 'org.eclipse.emf.common-2.12.0.jar'
require 'org.apache.xml.resolver-1.2.0.jar'
require 'org.eclipse.xtext.xbase.lib-2.12.0.jar'

java_import 'gov.nasa.jpl.imce.oml.model.descriptions.DescriptionsFactory'
java_import 'gov.nasa.jpl.imce.oml.model.descriptions.DescriptionKind'
java_import 'gov.nasa.jpl.imce.oml.model.graphs.ConceptDesignationTerminologyAxiom'
java_import 'gov.nasa.jpl.imce.oml.model.extensions.OMLCatalog'
java_import 'gov.nasa.jpl.imce.oml.model.extensions.OMLExtensions'
java_import 'gov.nasa.jpl.imce.oml.zip.OMLZipResourceSet'

java_import 'org.eclipse.emf.ecore.EClass'
java_import 'org.eclipse.emf.ecore.EObject'

CATALOG = '/Users/sjenkins/git/imce-caesar/europa.integration/resources/oml.catalog.xml'
DBOX_IRI = 'http://imce.jpl.nasa.gov/test/test/test'

desc_factory = DescriptionsFactory.eINSTANCE

oml_catalog_file = File.new(CATALOG)

dbox = desc_factory.createDescriptionBox
dbox.setIri(DBOX_IRI)
dbox.setKind(DescriptionKind::FINAL)
