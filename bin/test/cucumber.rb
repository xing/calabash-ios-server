#!/usr/bin/env ruby

require "luffa"
require "fileutils"
require "tmpdir"
require "bundler"

cucumber_args = "#{ARGV.join(" ")}"

server_dir = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))
calabash_framework = File.join(server_dir, 'calabash.framework')

# If calabash.framework was built by a previous step, use it.
unless File.exist?(calabash_framework)
  Dir.chdir server_dir do
    Luffa.unix_command("make framework")
  end
end

app = File.join(server_dir, "Products", "test-target", "app-cal", "LPTestTarget.app")

unless File.exist?(app)
  Dir.chdir server_dir do
    Luffa.unix_command("make app-cal")
  end
end

working_dir = File.join(server_dir, "cucumber")

Dir.chdir working_dir do
  Bundler.with_clean_env do

    FileUtils.rm_rf("reports")
    FileUtils.mkdir_p("reports")

    Luffa.unix_command("bundle update")

    require "run_loop"

    env_vars = {}

    cucumber_cmd = "bundle exec cucumber -p simulator -f json -o reports/cucumber.json -f junit -o reports/junit #{cucumber_args}"

    exit_code = Luffa.unix_command(cucumber_cmd, {:exit_on_nonzero_status => false,
                                                  :env_vars => env_vars})
    if exit_code == 0
      exit 0
    else
      exit 1
    end
  end
end

