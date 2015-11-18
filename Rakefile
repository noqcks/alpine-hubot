require 'rubygems'
require 'bundler/setup'
require 'json'
require 'open-uri'
require 'aws-sdk-core'
require 'set'
require 'autostacker24'

VERSION           = ENV['CIRCLE_BUILD_NUM'] || ENV['VERSION']
SANDBOX           = ENV['SANDBOX'] || ENV['GO_JOB_NAME'].nil? && `whoami`.strip

SERVICE           = 'telusdigital-hubot'
SERVICE_STACK     = SANDBOX ? "#{SANDBOX}-#{SERVICE}" : SERVICE
SERVICE_TEMPLATE  = File.read("#{SERVICE}-stack.json")

CLUSTER           = 'ecs-cluster'
CLUSTER_STACK     = SANDBOX ? "#{SANDBOX}-#{CLUSTER}" : CLUSTER
CLUSTER_TEMPLATE  = File.read("#{CLUSTER}-stack.json")

desc "create or update service #{SERVICE} stack"
task :create_or_update do

  fail('VERSION missing') unless VERSION #TODO: determine latest green version for sandboxed deploy

  parameters = {
    KeyName:                "telusdigital-key-pair-euwest1",
    SubnetID:               "subnet-7f885626",
    InstanceType:           "t2.micro",
    DesiredCapacity:        "1",
    MaxSize:                "1"
  }
  Stacker.create_or_update_stack(CLUSTER_STACK, CLUSTER_TEMPLATE, parameters)

  parameters = {
    SubnetID:               "subnet-7f885626",
    ContainerVersion:       VERSION
  }
  Stacker.create_or_update_stack(SERVICE_STACK, SERVICE_TEMPLATE, parameters, CLUSTER_STACK)

end

desc 'validate template'
task :validate do
  Stacker.validate_template(CLUSTER_TEMPLATE)
  Stacker.validate_template(SERVICE_TEMPLATE)
end

desc 'dump template'
task :dump do
  puts JSON.pretty_generate(JSON(Stacker.template_body(CLUSTER_TEMPLATE)))
  puts JSON.pretty_generate(JSON(Stacker.template_body(SERVICE_TEMPLATE)))
end

desc 'delete stack'
task :delete do
  Stacker.delete_stack(SERVICE_STACK)
  Stacker.delete_stack(CLUSTER_STACK)
end

task :default do
  puts
  puts 'Use one of the available tasks:'
  system 'rake -T'
end
