require 'rubygems'
require "bundler"
Bundler.setup

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'pg_csv'

require 'benchmark'
require 'fileutils'

class PgCsv
  def sql
    ""
  end

  def connection
    1
  end

  def load_data
    n = o(:times).to_i
    c = 0
    if @row_proc
      n.times do
        c += 1
        yield(@row_proc["#{c},#{c*2},#{c * 249},#{rand(100)},#{rand(n)},blablabla,hahah,ahah,ahaha,ahahah,ah,1.55234143\n"])
      end
    else
      n.times do
        c += 1
        yield("#{c},#{c*2},#{c * 249},#{rand(100)},#{rand(n)},blablabla,hahah,ahah,ahaha,ahahah,ah,1.55234143\n")
      end
    end
  end
end

filename = "./blah.test.file"
N = 500_000

tm = Benchmark.realtime{ PgCsv.new(:times => N, :type => :file).export(filename) }
puts "export file #{tm}"

tm = Benchmark.realtime{ PgCsv.new(:times => N, :type => :gzip).export(filename) }
puts "export gzip #{tm}"

tm = Benchmark.realtime{ PgCsv.new(:times => N, :type => :plain).export }
puts "export plain #{tm}"

tm = Benchmark.realtime{ File.open(filename, 'w'){|f| PgCsv.new(:times => N, :type => :stream).export(f) } }
puts "export stream #{tm}"

tm = Benchmark.realtime{ PgCsv.new(:times => N, :type => :yield).export{|row| row } }
puts "export yield #{tm}"

FileUtils.rm(filename) rescue nil
