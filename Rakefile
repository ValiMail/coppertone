require 'bundler/gem_tasks'

task default: :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color', '--format doc']
end

require 'rubocop/rake_task'

desc 'Run RuboCop on the lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
  # don't abort rake on failure
  task.fail_on_error = false
end

require 'json'
require 'yaml'
require 'fileutils'
desc 'Parse OpenSPF tests'

def spec_file_name(doc, output_path)
  description = doc['description']
  file_name = description.gsub(/[^\w\s_-]+/, '')
    .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
    .gsub(/\s+/, '_') + '_spec.rb'
  File.join(output_path, file_name)
end

INDENT_STRING = '  '
def indented_string(num_indents = 1)
  num_indents.times.map { INDENT_STRING }.join('')
end

def puts_prefixed_string(f, s, indent = 0)
  f.write indented_string(indent) unless indent == 0
  f.puts s
end

def empty_line(f)
  puts_prefixed_string(f, '', 0)
end

def write_zonedata(f, zonedata, indent = 1)
  puts_prefixed_string(f, 'let(:zonefile) do', indent)
  puts_prefixed_string(f, zonedata, indent + 1)
  puts_prefixed_string(f, 'end', indent)
  empty_line(f)
  dns_line = 'let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }'
  puts_prefixed_string(f, dns_line, indent)
  puts_prefixed_string(f, 'let(:options) { { dns_client: dns_client } }',
                       indent)
  empty_line(f)
end

def escape_quote(val)
  return unless val
  val.gsub(/'/) { |_s| "\\'" }
end

def clean_description(description)
  return unless description
  description.gsub("\n", ' ').gsub("'", '')
end

def as_array(val)
  return [] unless val
  val.is_a?(Array) ? val : [val]
end

def write_comment(f, comment, indent)
  return unless comment
  comment.lines do |comment_line|
    puts_prefixed_string(f, "# #{comment_line}", indent)
  end
end

def write_result(f, host, mailfrom, helo, indent)
  spf_result =
    "Coppertone::SpfService.authenticate_email('#{host}', '#{mailfrom}'," \
    " '#{helo}', options)"
  puts_prefixed_string(f, "result = #{spf_result}", indent)
end

def write_expects(f, results, explanation, indent)
  results_array = "[#{results.map { |r| ':' + r } .join(',')}]"
  code_expect = "expect(#{results_array}).to include(result.code)"
  puts_prefixed_string(f, code_expect, indent)
  return unless explanation
  exp_expect = "expect(result.explanation).to eq('#{explanation}')"
  puts_prefixed_string(f, exp_expect, indent)
end

def normalize_spec_args(spec)
  helo = escape_quote(spec['helo'])
  host = escape_quote(spec['host'])
  mailfrom = escape_quote(spec['mailfrom'])
  comment = escape_quote(spec['comment'])
  description = clean_description(spec['description'])
  results = as_array(spec['result'])
  explanation = escape_quote(spec['explanation'])
  [helo, host, mailfrom, comment, description, results, explanation]
end

def write_spec(f, spec, indent = 1)
  helo, host, mailfrom, comment, description, results, explanation =
    normalize_spec_args(spec)
  puts_prefixed_string(f, "it '#{description}' do", indent)
  write_comment(f, comment, indent + 1)
  write_result(f, host, mailfrom, helo, indent + 1)
  write_expects(f, results, explanation, indent + 1)
  puts_prefixed_string(f, 'end', indent)
  empty_line(f)
end

def write_doc(doc, output_path)
  open(spec_file_name(doc, output_path), 'w') do |f|
    puts_prefixed_string(f, "require 'spec_helper'")
    empty_line(f)
    description = doc['description']
    puts_prefixed_string(f, "describe '#{description}' do")
    write_zonedata(f, doc['zonedata'], 1)
    doc['tests'].each do |k, spec|
      spec['description'] ||= k
      write_spec(f, spec)
    end
    puts_prefixed_string(f, 'end')
  end
end

task :build_open_spf_test_suite do
  yml_file_name = 'rfc7208-tests.yml'
  yml_file_path = File.join(File.dirname(__FILE__), 'spec', yml_file_name)
  output_path = File.join(File.dirname(__FILE__), 'spec', 'open_spf')
  FileUtils.mkdir_p(output_path)
  documents = YAML.load_stream(File.open(yml_file_path).read)
  documents.each { |doc| write_doc(doc, output_path) }
end
