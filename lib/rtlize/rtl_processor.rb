module Rtlize
  class RtlProcessor
    def initialize(filename, &block)
      @filename = filename
      @source = block.call
    end

    def render(context, locals, &block)
      self.class.run(@filename, @source, context)
    end

    def self.run(filename, source, context)
      if context.pathname.basename.to_s.match(/\.rtl\.s?css/i)
        Rtlize::RTLizer.transform(source)
      else
        source
      end
    end

    def self.call(input)
      filename = input[:filename]
      source   = input[:data]
      context  = input[:environment].context_class.new(input)

      result = run(filename, source, context)
      context.metadata.merge(data: result)
    end
  end
end
