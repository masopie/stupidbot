# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{File.expand_path(File.dirname(__FILE__))}/.." unless defined?(DAEMON_ROOT) # rubocop:disable Style/MutableConstant

require 'rubygems'
require 'bundler/setup'

module DaemonKit
  class << self
    def boot!
      return if booted?

      GemBoot.new.run
    end

    def booted?
      defined?(DaemonKit::Initializer)
    end
  end

  class Boot
    def run
      load_initializer
      DaemonKit::Initializer.run
    end
  end

  class GemBoot < Boot
    def load_initializer
      require 'rubygems' unless defined?(::Gem)

      gem 'daemon-kit'

      require 'daemon_kit/initializer'
    rescue ::Gem::LoadError
      $stderr.puts "You are missing the daemon-kit gem. Please run 'sudo gem install daemon-kit'"
      exit 1
    end
  end
end

DaemonKit.boot!
