require 'rake'

inputs = {
  'stack_item_label'    => 'exmpl',
  'stack_item_fullname' => 'Full Terraform AWS VPC deployment example',
  'domain_name'         => 'unif.io',
  'ami'                 => 'ami-xxxxxx',
  'key_name'            => 'example',
  'ssh_user'            => 'ec2-user',
}

task :default => :verify

desc "Verify the stack"
task :verify do

  vars = []
  inputs.each() do |var, value|
    vars.push("-var #{var}=\"#{value}\"")
  end

  ['basic', 'full_stack'].each do |stack|
    task_args = {:stack => stack, :args => vars.join(' ')}
    Rake::Task['clean'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
    Rake::Task['plan'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
  end
end

desc "Remove existing local state if present"
task :clean, [:stack] do |t, args|
  sh "cd examples/#{args['stack']} && rm -fr .terraform *.tfstate*"
end

desc "Create execution plan"
task :plan, [:stack, :args] do |t, args|
  sh "cd examples/#{args['stack']} && terraform get && terraform plan -module-depth=-1 -input=false #{args['args']}"
end
