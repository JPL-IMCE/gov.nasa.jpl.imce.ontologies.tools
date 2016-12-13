#--
#
#    $HeadURL$
#
#    $LastChangedRevision$
#    $LastChangedDate$
#
#    $LastChangedBy$
#
#    Copyright (c) 2008-2014 California Institute of Technology.
#    All rights reserved.
#
#    Library for Sesame Audits.
#
#++

require 'logger'
require 'thread'
require 'rexml/document'
require 'jpl/rdf/sesame'

module OntologyAudit
  class TestSuites < REXML::Element
    def initialize
      super('testsuites')
    end
  end

  class TestSuite < REXML::Element
    def initialize(name)
      super('testsuite')
      add_attribute('name', name)
    end
  end

  class TestCase < REXML::Element
    def initialize(name)
      super('testcase')
      add_attribute('name', name)
    end
  end

  class Failure < REXML::Element
    def initialize(text = nil)
      super('failure')
      self << REXML::Text.new(text) if text
    end
  end

  class Query
    
    require 'erb'
    
    def initialize(qstring = '', options = OpenStruct.new)
      @qstring = qstring
      @infer = options.audit_options.infer rescue false
      @binding = options.binding
      @logger = options.logger
    end

    attr_accessor :qstring, :options

    def run(model, result = nil, &block)
      if result
        exp_qstring = ERB.new(@qstring).result(@binding)
        params = result.marshal_dump.keys.inject({}) do |b, method|
          b["$#{method.to_s}"] = result.send(method).to_uriref
          b
        end.merge({'query' => exp_qstring , 'queryLn' => 'sparql'})
        params['infer'] = @infer ? @infer : 'false'
        model.query(params, &block)
      else
        yield(nil)
      end
    end

  end
  
  class Filter
    
    def initialize(proc, options = OpenStruct.new)
      @proc = proc
      @application = options.application
      @logger = options.logger
    end
    
    def run(model, input, &block)
      @application.instance_exec(input, block, &@proc)
      yield(nil) unless input
    end
        
  end

  class Evaluator
    
    def initialize(options = OpenStruct.new)
      @predicate = proc { |r| r.audit_case_ok && r.audit_case_ok.true? ? [true, nil] :
        [false, r.audit_case_text ? r.audit_case_text.to_s : 'Failure.' ] }
      @case_name = proc { |r| r.audit_case_name }
      @application = options.application
    end

    attr_writer :predicate, :case_name

    def run(result)
      name = @application.instance_exec(result, &@case_name)
      test_case = TestCase.new(name)
      success, failure_text = @application.instance_exec(result, &@predicate)
      unless success
        test_case << Failure.new(failure_text)
      end
      test_case
    end

  end

  class Audit
    
    def initialize(name, options = OpenStruct.new)
      @name = name
      @prologues = []
      @processors = []
      @evaluator = OntologyAudit::Evaluator.new(options)
      @application = options.application
    end

    def add_prologue(prologue)
      @prologues << prologue
    end
    
    def add_processor(processor)
      @processors << processor
    end
    alias :<< :add_processor

    attr_reader :processors, :name
    attr_accessor :evaluator
    
    def run(model)
           
      Thread.abort_on_exception = true

      # Run prologues.
      
      @prologues.each do |prologue|
        @application.instance_eval(&prologue)
      end
      
      # Create inter-thread queues.

      queues = 0.upto(processors.length).map { Queue.new }

      # Seed first queue with trigger result and end sentinel.

      queues.first << OpenStruct.new
      queues.first << nil

      # Create processor threads.

      processors.each do |processor|
        in_queue = queues.shift
        out_queue = queues.first
        Thread.new(processor, in_queue, out_queue) do |qry, in_q, out_q|
          loop do
            result = in_q.shift
            processor.run(model, result) do |r|
              out_q << r
            end
            break unless result
          end
        end
      end

      # Create test suite for results.

      test_suite = OntologyAudit::TestSuite.new(@name)

      # Run evaluator.

      ev_thread = Thread.new do
        while result = queues.first.shift
          test_suite << evaluator.run(result)
        end
      end
      
      # Wait for evaulator thread (and raise exception on failure.)
      
      ev_thread.value
      
      # Return test suite.
      
      test_suite

    end
  end

  class Parser
    
    def initialize(options = OpenStruct.new)
      @audit = nil
      @options = options
      @logger = @options.logger
    end
    attr_reader :audits

    def parse(input, path = nil)
      @audits = []
      eval(input, nil, path)
      @audits
    end

    def name(string)
      @audits << @audit = OntologyAudit::Audit.new(string, @options)
    end

    def prologue(&block)
      raise 'no audit name found' unless @audit
      @audit.add_prologue(block)
    end

    def query(qstring)
      raise 'no audit name found' unless @audit
      @audit << OntologyAudit::Query.new(qstring, @options)
    end

    def filter(&block)
      raise 'no audit name found' unless @audit
      @audit << OntologyAudit::Filter.new(block, @options)
    end
    
    def predicate(&block)
      raise 'no audit name found' unless @audit
      @audit.evaluator.predicate = block
    end

    def case_name(&block)
      raise 'no audit name found' unless @audit
      @audit.evaluator.case_name = block
    end

  end

  class Battery
    
    require 'find'
    
    AUDIT_FILENAME_PATTERN = /.*\.rb\z/
    
    def initialize(options = OpenStruct.new)
      @options = options
      @logger = @options.logger
      @audits = {}
    end

    attr_reader :audits

    def add_audit(audit)
      raise "audit name collision (#{audit.name})" if @audits.include?(audit.name)
      @audits[audit.name] = audit
      @logger.log(Logger::INFO, "battery #{self.to_s} added audit '#{audit.name}'") if @logger
    end
    alias :<< :add_audit

    def add_audit_file(path)
      @logger.log(Logger::DEBUG, "open audit file '#{path}'") if @logger
      audit_data = File.open(path).read
      @logger.log(Logger::DEBUG, "read data: #{audit_data}") if @logger
      OntologyAudit::Parser.new(@options).parse(audit_data, path).each do |audit|
        add_audit(audit)
      end
    end

    def add_audit_dir(path)
      Dir.open(path) do |d|
        d.each do |f|
          next unless f =~ AUDIT_FILENAME_PATTERN
          add_audit_file("#{path}/#{f}")
        end
      end
    end

    def add_audit_tree(path)
      Find.find(path) do |p|
        if FileTest.directory?(p)
          add_audit_dir(p)
        end
      end
    end

    def run(model)
      test_suites = OntologyAudit::TestSuites.new
      @audits.each_value do |audit|
        @logger.log(Logger::INFO, "battery #{self.to_s} starting audit '#{audit.name}'") if @logger
        test_suites << audit.run(model)
      end
      test_suites
    end

  end

end

if __FILE__ == $0

  # https://bugs.eclipse.org/bugs/show_bug.cgi?id=323736

  unless defined?(Test::Unit::UI::SILENT)
    module Test
      module Unit
        module UI
          SILENT = false
        end

        class AutoRunner
          def output_level=(level)
            self.runner_options[:output_level] = level
          end
        end
      end
    end
  end

  unless Test::Unit::TestCase.respond_to?(:assert_empty)
    class Test::Unit::TestCase
      def assert_empty(x)
        assert(x.empty?)
      end
      def assert_not_empty(x)
        assert(!x.empty?)
      end
    end
  end

  HOST = 'localhost'
  PORT = '8080'
  PATH = 'openrdf-sesame'
  ID = 'geography'
  FAILURE_NAME = 'failure'
  AUDIT_NAME = 'every city is a captital'
  QSTRING1 = 'SELECT DISTINCT ?cty WHERE { ?cty rdf:type <http://www.mooney.net/geo#City>. }'
  QSTRING2 = %q{
    SELECT DISTINCT ?audit_case_name ?audit_case_ok
    WHERE {
      BIND(?cty AS ?audit_case_name)
      BIND(exists {?cty rdf:type <http://www.mooney.net/geo#Capital>} AS ?audit_case_ok)
    }
  }
  QSTRING3 = %q{
    SELECT DISTINCT ?audit_case_name ?audit_case_ok
    WHERE {
      ?cty rdf:type <http://www.mooney.net/geo#City>.
      BIND(?cty AS ?audit_case_name)
      BIND(exists {?cty rdf:type <http://www.mooney.net/geo#Capital>} AS ?audit_case_ok)
    }
  }

  class TestQuery < Test::Unit::TestCase
    
    def setup
      @session = RDF::Sesame::Session.new(HOST, PORT, PATH)
      @model = @session.model(ID)
    end

    def test_query

      query = OntologyAudit::Query.new(QSTRING1)
      assert_equal(QSTRING1, query.qstring)

      query.run(@model, OpenStruct.new) do |resp|
        assert_instance_of(OpenStruct, resp)
      end

    end

    def teardown
      @session.finish
    end

  end

  class TestFilter < Test::Unit::TestCase
    
    def test_filter

      filter = OntologyAudit::Filter.new(proc { |r, emit| emit.call(r) if r })

      filter.run(nil, OpenStruct.new) do |resp|
        assert_instance_of(OpenStruct, resp)
      end

    end

  end

  class TestEvaluator < Test::Unit::TestCase

    TEST_NAME = 'test'
    TEST_TEXT = 'Failure.'
    
    def test_evaluator

      result = OpenStruct.new
      result.audit_case_name = TEST_NAME
      result.audit_case_ok = RDF::TrueLiteral.new
      result.audit_case_text = nil
      test_case = nil

      evaluator = OntologyAudit::Evaluator.new

      test_case = evaluator.run(result)

      assert_instance_of(OntologyAudit::TestCase, test_case)
      assert_equal(test_case.attribute('name').value, TEST_NAME)
      failures = test_case.get_elements(FAILURE_NAME)
      assert_empty(failures)

      result.audit_case_ok = RDF::FalseLiteral.new
      result.audit_case_text = RDF::StringLiteral.new(TEST_TEXT)

      assert_nothing_raised(RuntimeError) do
        test_case = evaluator.run(result)
      end

      failures = test_case.get_elements(FAILURE_NAME)
      assert_not_empty(failures)
      assert_equal(failures.first.text, TEST_TEXT)

    end

  end

  class TestAuditParser < Test::Unit::TestCase
    
    def setup
      @session = RDF::Sesame::Session.new(HOST, PORT, PATH)
      @model = @session.model(ID)
      @options = OpenStruct.new
      @options.application = self
      @options.binding = binding
      @options.audit_options = OpenStruct.new
    end
    
    def teardown
      @session.finish
    end

  end
  
  class TestAudit < TestAuditParser
    
    def test_audit_1

      query1 = OntologyAudit::Query.new(QSTRING1)
      query2 = OntologyAudit::Query.new(QSTRING2)

      evaluator = OntologyAudit::Evaluator.new

      audit = OntologyAudit::Audit.new(AUDIT_NAME)
      audit.processors << query1
      audit.processors << query2
      audit.evaluator = evaluator

      result = audit.run(@model)
      assert_instance_of(OntologyAudit::TestSuite, result)
      test_cases = result.get_elements('testcase')
      assert_equal(351, test_cases.length)

      successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
      assert_equal(0, successes.length)

    end
    
    def test_audit_2
      
      @options.audit_options.infer = 'false'
      
      query = OntologyAudit::Query.new(QSTRING3, @options)

      evaluator = OntologyAudit::Evaluator.new

      audit = OntologyAudit::Audit.new(AUDIT_NAME)
      audit.processors << query
      audit.evaluator = evaluator

      result = audit.run(@model)
      assert_instance_of(OntologyAudit::TestSuite, result)
      test_cases = result.get_elements('testcase')
      assert_equal(351, test_cases.length)

      successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
      assert_equal(0, successes.length)

    end
    
    def test_audit_3
      
      @options.audit_options.infer = 'true'
      
      query = OntologyAudit::Query.new(QSTRING3, @options)

      evaluator = OntologyAudit::Evaluator.new

      audit = OntologyAudit::Audit.new(AUDIT_NAME)
      audit.processors << query
      audit.evaluator = evaluator

      result = audit.run(@model)
      assert_instance_of(OntologyAudit::TestSuite, result)
      test_cases = result.get_elements('testcase')
      assert_equal(402, test_cases.length)

      successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
      assert_equal(51, successes.length)

    end

    def test_audit_4
      
      @options.audit_options.infer = 'true'
      
      query = OntologyAudit::Query.new(QSTRING3, @options)

      evaluator = OntologyAudit::Evaluator.new

      audit = OntologyAudit::Audit.new(AUDIT_NAME)
      audit.processors << query
      audit.evaluator = evaluator

      result = audit.run(@model)
      assert_instance_of(OntologyAudit::TestSuite, result)
      test_cases = result.get_elements('testcase')
      assert_equal(402, test_cases.length)

      successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
      assert_equal(51, successes.length)

    end

    def test_audit_5
      
      @options.audit_options.infer = 'true'

      prologue = proc { @bool = true }
        
      query = OntologyAudit::Query.new(QSTRING3, @options)

      evaluator = OntologyAudit::Evaluator.new(@options)
      evaluator.predicate = proc { |r| [ @bool && r.audit_case_ok && r.audit_case_ok.true? , '' ] }

      audit = OntologyAudit::Audit.new(AUDIT_NAME, @options)
      audit.add_prologue(prologue)
      audit.processors << query
      audit.evaluator = evaluator

      result = audit.run(@model)
      assert_instance_of(OntologyAudit::TestSuite, result)
      test_cases = result.get_elements('testcase')
      assert_equal(402, test_cases.length)

      successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
      assert_equal(51, successes.length)
      
    end
  end

  class TestParser < TestAuditParser

    require 'tempfile'

    AUDIT_PATH = 'data/Audit/test'
    AUDIT_BASENAMES = %w{
      every-city-is-a-capital-1.rb
      every-city-is-a-capital-2.rb
      every-city-is-a-capital-3.rb
      every-city-is-a-capital-4.rb
      every-city-is-a-capital-5.rb
    }
    AUDIT_FILES = AUDIT_BASENAMES.map { |b| "#{AUDIT_PATH}/#{b}" }

    def setup
      super
      @tempfile = Tempfile.new('Audit')
      @tempname = @tempfile.path
      AUDIT_FILES.each do |f|
        @tempfile.write(File.open(f).read + "\n")
      end
      @tempfile.rewind
    end

    def test_parser
      
      @options.audit_options.infer = 'true'
      parser = OntologyAudit::Parser.new(@options)
      audit_files = AUDIT_FILES + [@tempname]
      audit_files.each do |file|
        File.open(file) do |io|
          parser.parse(io.read, file)
          parser.audits.each do |audit|
            assert_instance_of(OntologyAudit::Audit, audit, audit.name)

            result = audit.run(@model)
            assert_instance_of(OntologyAudit::TestSuite, result)
            test_cases = result.get_elements('testcase')
            assert_equal(402, test_cases.length, audit.name)

            successes = test_cases.select { |tc| tc.get_elements(FAILURE_NAME).empty? }
            assert_equal(51, successes.length, audit.name)
          end
        end
      end

    end
    
  end

  class TestBattery < TestParser
    
    def test_battery_1

      query1 = OntologyAudit::Query.new(QSTRING1)
      query2 = OntologyAudit::Query.new(QSTRING2)
      query3 = OntologyAudit::Query.new(QSTRING3)
      
      audit1 = OntologyAudit::Audit.new(AUDIT_NAME + ' 1')
      audit1 << query1
      audit1 << query2
      
      audit2 = OntologyAudit::Audit.new(AUDIT_NAME + ' 2')
      audit2 << query3
      
      battery = OntologyAudit::Battery.new
      battery << audit1
      battery << audit2
      
      test_suites = battery.run(@model)
      assert_instance_of(OntologyAudit::TestSuites, test_suites)
      assert_equal(2, test_suites.get_elements('testsuite').length)

    end

    def test_battery_2
      
      battery = OntologyAudit::Battery.new
      battery.add_audit_file(AUDIT_FILES.first)
      assert_equal(1, battery.audits.length)
      
    end
    
    def test_battery_3
      
      battery = OntologyAudit::Battery.new
      battery.add_audit_dir(AUDIT_PATH)
      assert_equal(AUDIT_FILES.length, battery.audits.length)
      
    end
    
    def test_battery_4
      
      battery = OntologyAudit::Battery.new
      battery.add_audit_tree(AUDIT_PATH)
      assert_equal(AUDIT_FILES.length, battery.audits.length)
      
    end
    
  end
end