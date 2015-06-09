source 'https://rubygems.org'

group :development, :test do
  gem 'rake'
  gem 'rspec-puppet', '>= 2.2.0'
  gem 'puppetlabs_spec_helper'
#  gem 'rspec-system-puppet', '~>2.0'
  gem 'puppet-lint', '~> 0.3.2'
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
