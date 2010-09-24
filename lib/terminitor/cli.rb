require 'thor'
require File.expand_path('../../terminitor',  __FILE__)
module Terminitor
  class Cli < Thor
    include Thor::Actions
    include Terminitor::Runner

    def self.source_root; File.expand_path('../../',__FILE__); end

    desc "start PROJECT_NAME", "runs the terminitor project"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def start(project="")
      path = resolve_path(project)
      if File.exists?(path)
        Terminitor::MacCore.new(path).process!
      else
        if project
          say "'#{File.basename(path)}' doesn't exist! Please run 'terminitor open #{project}'"
        else
          say "Termfile doesn't exist! Please run 'terminitor open' in project directory"
        end
      end
    end

    desc "list", "lists all terminitor scripts"
    def list
      say "Global scripts: \n"
      Dir.glob("#{ENV['HOME']}/.terminitor/*").each do |file|
        say "  * #{File.basename(file).gsub('.yml','')} #{grab_comment_for_file(file)}"
      end
    end

    desc "setup", "create initial root terminitor folder"
    def setup
      empty_directory "#{ENV['HOME']}/.terminitor"
    end

    desc "open PROJECT_NAME", "open project yaml"
    method_option :root,    :type => :string, :default => '.', :aliases => '-r'
    method_option :editor,  :type => :string, :default => nil, :aliases => '-c'
    def open(project="")
      path =  resolve_path(project)
      template "templates/example.yml.tt", path, :skip => true
      open_in_editor(path,options[:editor])
    end
    
    desc "generate", "create a Termfile in directory"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def create
      invoke :open, [], :root => options[:root]
    end
    
    desc "delete PROJECT", "delete project script"
    method_option :root, :type => :string, :default => '.', :aliases => '-r'
    def delete(project="")
      path = resolve_path(project)
      remove_file path
    end
    
    no_tasks do
      
      def grab_comment_for_file(file)
        first_line = File.readlines(file).first
        first_line =~ /^\s*?#/ ? ("-" + first_line.gsub("#","")) : "\n"
      end
    end
        
  end
end