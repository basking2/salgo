# 
# The MIT License
# 
# Copyright (c) 2010 Samuel R. Baskinger
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 

require 'rake'

Gem::Specification.new do |spec|
    spec.name = 'salgo'
    spec.version = '1.0.1'
    spec.platform = Gem::Platform::RUBY
    spec.summary = 'simply algorithms'
    spec.email = 'basking2@rubyforge.org.com'
    spec.homepage = 'http://salgo.rubyforge.org'
    spec.rubyforge_project='http://salgo.rubyforge.org/'
    spec.author = 'Sam Baskinger'
    spec.description='A collection of algorithms and datastructure for ruby written in ruby.'
    spec.required_ruby_version = '>= 1.6.8'
    # spec.require_paths = [ 'lib' ] (defalt)
    spec.require_paths = [ 'lib' ]
    spec.files = FileList[ 'lib/**/*.rb' ].to_a
    spec.add_dependency('log4r', '>=1.0.5')
    #spec.add_dependency('sources', '>=0.0.1')
    #spec.add_dependency('mechanize', '>=0.9.3') # Required for blog clustering script.
    #spec.add_dependency('stemmer', '>=1.0.1') # Word stemming
    #spec.add_dependency('nokogiri', '>=1.4.1') # HTML parsing.
    spec.test_files = FileList[ 'tests/*rb', 'tests/**/*.rb' ] .to_a
    spec.has_rdoc = true
end
