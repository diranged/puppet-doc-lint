class PuppetDocLint
  class Parser

    def initialize(file)
      # Read file and return parsed object
      if File.exists?(file)
        @file = File.expand_path(file)

        string = File.open(@file, 'rb') { |file| file.read }

        if string.match(/\(\{[\w]*\}\)/)
          puts "Found a Hash!"
          puts "Currently, hashes will break puppet current parser"
        end

        pparser = Puppet::Parser::Parser.new('production')

        pparser.import(@file)

        # Find object in list of hostclasses
        pparser.environment.known_resource_types.hostclasses.each do |x|
          @object = x.last if x.last.file == @file
        end
        # Find object in list of definitions
        pparser.environment.known_resource_types.definitions.each do |x|
          @object = x.last if x.last.file == @file
        end

      else
        'File does not exist'
      end
    end

    # Read parameters from parsed object, returns hash of parameters and default
    # values
    def parameters
      result = (defined? @object.arguments) ? @object.arguments : nil
      result
    end

    # Read class from parsed object, returns string containing class
    def klass
      @object.name if (defined? @object.class.name)
    end

    # Read RDOC contents from parsed object, returns hash of paragraph headings
    # and the following paragraph contents
    #(i.e. parameter and parameter documentation)
    def docs
      if !@object.doc.nil?
        rdoc            = RDoc::Markup.parse(@object.doc)
        docs            = {}
        rdoc.parts.each do |part| 
          if part.respond_to?(:items)
            part.items.each do |item|
              key       = item.label.to_s.tr('^A-Za-z0-9_-', '')
              docs[key] = item.parts.first.parts
            end # do item
          end # endif
        end # do parm
        docs.kill_blank_keys
      end # if nil?
    end # def docs
  end # class Parser
end # module PuppetDocLint
