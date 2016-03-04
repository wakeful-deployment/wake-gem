require 'json'
require_relative './cluster'

module CLI
  extend GLI::App

  program_desc 'an opinionated deployment cli'

  version Wake::VERSION

  subcommand_option_handling :normal
  arguments :strict

  # global options

  desc 'Verbose output'
  switch :v, :verbose, negatable: false

  desc 'Very verbose output'
  switch :vv, :"very-verbose", negatable: false

  desc 'Current cluster to work in'
  flag :c, :cluster, default_value: :default

  pre do |global, command, options, args|
    true # true means continue - this is important
  end

  post do |global, command, options, args|
  end

  on_error do |exception|
    true # false means to skip default error handling - this is important
  end

  # commands

  desc 'Manage known clusters'
  command :clusters do |c|
    c.desc 'List all known clusters'
    c.command :list do |c|
      c.action do |global_options, options, args|
        clusters = Cluster.list
        puts "#{clusters.count} cluster(s) total:"
        puts if clusters.count > 0
        clusters.each do |name, info|
          puts "#{name}:"
          puts JSON.pretty_generate(info).indent(2)
          puts
        end
        puts if clusters.count > 0
        puts "TODO: describe how to add an alreadying created cluster to this list"
      end
    end

    c.desc 'Create a new cluster'
    c.arg '<name>'
    c.command :create do |c|
      c.desc 'IaaS platform to use'
      c.flag :i, :iaas

      c.desc 'Datacenter name or geographic region'
      c.flag :d, :datacenter

      c.desc 'Orchestrator for scheduling containers'
      c.flag :o, :orchestrator

      c.action do |global_options, options, args|
        help_now! "iaas is required" if options[:iaas].nil?
        help_now! "datacenter is required" if options[:datacenter].nil?
        help_now! "orchestrator is required" if options[:orchestrator].nil?

        p ["clusters create", :global_options, global_options, :options, options, :args, args]

        Cluster.create name: args.first, iaas: options[:iaas], datacenter: options[:datacenter], orchestrator: options[:orchestrator]
      end
    end

    c.desc 'Delete a cluster'
    c.arg '<name>'
    c.command :delete do |c|
      c.action do |global_options, options, args|
        p ["clusters delete", :global_options, global_options, :options, options, :args, args]

        Cluster.delete name: args.first
      end
    end

    c.desc 'Set the default cluster'
    c.arg '<name>'
    c.command :"set-default" do |c|
      c.action do |global_options, options, args|
        p ["clusters set-default", :global_options, global_options, :options, options, :args, args]

        Cluster.set_default name: args.first
      end
    end
  end

  desc 'Build a container image from the current directory'
  command :build do |c|
    c.desc 'Revision to build from'
    c.long_desc 'Revision to build from - can be any git addressable revision: sha, branch, or tag'
    c.flag :r, :revision, default_value: 'master'

    c.desc 'Push to registry'
    c.switch :p, :push, default_value: true

    c.action do |global_options, options, args|
      p ["build", :global_options, global_options, :options, options, :args, args]

      Docker.build revision: options[:revision], push: options[:push]
    end
  end

  desc 'Run container images in the cluster'
  arg '<name>'
  command :run do |c|
    c.desc 'Image to run'
    c.long_desc 'Image to run can be docker hub path or full URI to private registry'
    c.flag :i, :image

    c.desc 'Amount to run'
    c.long_desc 'Amount of containers to start from the image'
    c.flag :a, :amount, default_value: 1, type: Fixnum

    c.action do |global_options, options, args|
      help_now! "image is required" if options[:image].nil?
      help_now! "service is required" if options[:service].nil?

      p ["run", :global_options, global_options, :options, options, :args, args]

      iaas = IaaS.fetch()
      orchestrator = Orchestrator.fetch(iaas: iaas)
      orchestrator.run(name: args.first, image: options[:image], amount: options[:amount])
    end
  end

  desc 'Rolling replace with a new container image for a service'
  arg '<name>'
  command :upgrade do |c|
    c.desc 'New image to run'
    c.long_desc 'New image to run can be docker hub path or full URI to private registry'
    c.flag :i, :image

    c.desc 'Perform a canary test'
    c.long_desc 'Perform a canary test by deploying one image, waiting some time, and then deploying the rest'
    c.switch :canary, negatable: false

    c.action do |global_options, options, args|
      help_now! "image is required" if options[:image].nil?

      p ["upgrade", :global_options, global_options, :options, options, :args, args]

      iaas = IaaS.fetch()
      orchestrator = Orchestrator.fetch(iaas: iaas)
      orchestrator.upgrade(name: args.first, image: options[:image])
    end
  end

  desc 'Scale a service in a cluster'
  arg '<name>'
  command :scale do |c|
    c.desc 'Amount desired running'
    c.long_desc 'Amount of desired containers - will either subtract or add from the current amount in the cluster'
    c.flag :a, :amount, type: Fixnum

    c.action do |global_options,options,args|
      help_now! "amount is required" if options[:amount].nil?

      p ["scale", :global_options, global_options, :options, options, :args, args]

      iaas = IaaS.fetch()
      orchestrator = Orchestrator.fetch(iaas: iaas)
      orchestrator.scale(name: args.first, amount: options[:amount])
    end
  end

  desc 'Manage application secrets'
  command :secrets do |c|
    c.desc 'List all secrets for an application'
    c.command :list do |c|
      c.desc 'Application name to manage secrets of'
      c.flag :a, :app, :application

      c.action do |global_options, options, args|
        help_now! "application is required" if options[:application].nil?

        p ["secrets list", :global_options, global_options, :options, options, :args, args]
      end
    end

    c.desc 'Get a secret for an application'
    c.arg '<NAME>'
    c.command :get do |c|
      c.desc 'Application name to manage secrets of'
      c.flag :a, :app, :application

      c.action do |global_options, options, args|
        help_now! "application is required" if options[:application].nil?

        p ["secrets list", :global_options, global_options, :options, options, :args, args]
      end
    end

    c.desc 'Set secret(s) for an application'
    c.arg '<NAME=value>', :multiple
    c.command :set do |c|
      c.desc 'Application name to manage secrets of'
      c.flag :a, :app, :application

      c.action do |global_options, options, args|
        help_now! "application is required" if options[:application].nil?

        p ["secrets list", :global_options, global_options, :options, options, :args, args]
      end
    end
  end

  # desc 'Manage local plugins'
  # command :plugins do |c|
  #   c.desc 'List installed plugins'
  #   c.command :list do |c|
  #     c.action do |global_options, options, args|
  #       p ["plugins list", :global_options, global_options, :options, options, :args, args]
  #     end
  #   end

  #   c.desc 'Install a plugin'
  #   c.arg '<name>'
  #   c.command :install do |c|
  #     c.action do |global_options, options, args|
  #       p ["plugins install", :global_options, global_options, :options, options, :args, args]
  #     end
  #   end

  #   c.desc 'Remove a plugin'
  #   c.arg '<name>'
  #   c.command :remove, :uninstall do |c|
  #     c.action do |global_options, options, args|
  #       p ["plugins remove", :global_options, global_options, :options, options, :args, args]
  #     end
  #   end

  #   c.desc 'Search remotely for a plugin to use'
  #   c.arg '<query>', :multiple
  #   c.command :search do |c|
  #     c.action do |global_options, options, args|
  #       p ["plugins search", :global_options, global_options, :options, options, :args, args]
  #     end
  #   end
  # end
end
