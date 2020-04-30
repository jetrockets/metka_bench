require 'benchmark/memory'

module Benchmark
  module Memory
    class Job
      class IOOutput
        class EntryFormatter
          # benchmark-memory has uncofigurable reporting format, so to align it with general Benchmark format
          # this method is being overridden
          def to_s
            output = StringIO.new
            output << entry.label.ljust(22)

            first, *rest = *entry.measurement

            output << "#{MetricFormatter.new(first)}\n"
            rest.each do |metric|
              output << "#{' ' * 22}#{MetricFormatter.new(metric)}\n"
            end

            output.string
          end
        end
      end
    end
  end
end
