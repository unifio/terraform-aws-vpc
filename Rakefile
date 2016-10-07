require 'rake'
require 'dotenv'

Dotenv.load(".env")

task :default => :verify

desc "Verify the stack"
task :verify do

  %w(basic full_stack).each do |stack|
    task_args = {:stack => stack, :tf_img => ENV['TF_IMG'], :tf_cmd => ENV['TF_CMD']}
    Rake::Task['clean'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
    Rake::Task['check_style'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
    Rake::Task['get'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
    Rake::Task['plan'].execute(Rake::TaskArguments.new(task_args.keys, task_args.values))
  end
end

desc "Remove existing local state if present"
task :clean, [:stack] do |t, args|
  sh "cd examples/#{args['stack']} && rm -fr .terraform *.tfstate*"
end

desc "Check style"
task :check_style, [:stack, :tf_img, :tf_cmd] do |t, args|
  sh "[ $(#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} fmt -write=false | wc -l) -eq 0 ]"
end

desc "Create execution plan"
task :plan, [:stack, :tf_img, :tf_cmd] do |t, args|
  sh "#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} plan -module-depth=-1 -input=false -var-file /data/examples/#{args['stack']}.tfvars"
end

desc "Get modules"
task :get, [:stack, :tf_img, :tf_cmd] do |t, args|
  sh "#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} get"
end

desc "Get output"
task :output, [:stack, :tf_img, :tf_cmd, :output] do |t, args|
  sh "#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} output #{args['output']}"
end

desc "Apply stack"
task :apply, [:stack, :tf_img, :tf_cmd, :var_file] do |t, args|
  sh "#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} apply -var-file /data/examples/#{args['var_file']}"
end

desc "Destroy stack"
task :destroy, [:stack, :tf_img, :tf_cmd, :var_file] do |t, args|
  sh "#{args['tf_cmd']} -v `pwd`:/data -w /data/examples/#{args['stack']} #{args['tf_img']} destroy -force -var-file /data/examples/#{args['var_file']}"
end
