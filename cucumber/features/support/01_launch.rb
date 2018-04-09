require 'calabash-cucumber/launcher'

# You can find examples of more complicated launch hooks in these
# two repositories:
#
# https://github.com/calabash/ios-smoke-test-app/blob/master/CalSmokeApp/features/support/01_launch.rb
# https://github.com/calabash/ios-webview-test-app/blob/master/CalWebViewApp/features/support/01_launch.rb

module Calabash::Launcher
  @@launcher = nil

  def self.launcher
    @@launcher ||= Calabash::Cucumber::Launcher.new
  end

  def self.launcher=(launcher)
    @@launcher = launcher
  end
end

Before("@no_relaunch") do
  @no_relaunch = true
end

Before("@acquaint") do
  if !xamarin_test_cloud?
    @acquaint_options = Acquaint.options
  end
end

Before("@device_agent_test_app") do
  if !xamarin_test_cloud?
    @device_agent_test_app_options = TestApp.options
  end
end

Before("@skip_embedded_server") do
  if !xamarin_test_cloud?
    @relaunch = true
    @skip_embedded_server_options = {}

    # See features/steps/dylib_injection.rb
    core_sim = test_target_core_sim
    core_sim.send(:uninstall_app_with_simctl)
    core_sim.install

    app = installed_test_target_app
    server_id = lpserver_embedded_version
    if !server_id
      raise %Q[
Could not find LPSERVERID embedded in app calabash.framework not linked
]
      exit 1
    end

    @skip_embedded_server_options[:env] = {
      "XTC_SKIP_LPSERVER_TOKEN" => server_id.split("=")[1],
      "DYLD_INSERT_LIBRARIES" => File.join(app.path, "libCalabashFAT.dylib")
    }
  end
end

Before("@german") do
  if !xamarin_test_cloud?
    target = ENV["DEVICE_TARGET"] || RunLoop::Core.default_simulator

    simulator = RunLoop::Device.device_with_identifier(target)

    RunLoop::CoreSimulator.erase(simulator)
    RunLoop::CoreSimulator.set_locale(simulator, "de")
    RunLoop::CoreSimulator.set_language(simulator, "de")

    @args = ["-AppleLanguages", "(de)", "-AppleLocale", "de"]
  end
end

Before("@port_from_env") do |scenario|
  if !xamarin_test_cloud?
    port = 37266
    @port_from_env_options = {
      env: { "LPF_SERVER_PORT" => port },
      terminate_aut_before_test: true
    }

    @original_endpoint = Calabash::Cucumber::Environment.device_endpoint
    uri = URI.parse(@original_endpoint)

    new_endpoint = "#{uri.scheme}://#{uri.host}:#{port}"
    ENV["DEVICE_ENDPOINT"] = new_endpoint
  end
end

Before do |scenario|
  launcher = Calabash::Launcher.launcher

  if @acquaint_options
    options = @acquaint_options
  elsif @device_agent_test_app_options
    options = @device_agent_test_app_options
  elsif @skip_embedded_server_options
    options = @skip_embedded_server_options
  elsif @port_from_env_options
    options = @port_from_env_options
  else
    options = {
      # Add launch options here.
      # Stick with defaults; preferences on device is not stable
      # :uia_strategy => :preferences
    }
  end

  if @args
    options[:args] = @args.dup
    @args = nil
  end

  relaunch = true

  if @no_relaunch
    begin
      launcher.ping_app
      attach_options = options.dup
      attach_options[:timeout] = 1
      launcher.attach(attach_options)
      relaunch = launcher.device == nil
    rescue => e
      RunLoop.log_info2("Tag says: don't relaunch, but cannot attach to the app.")
      RunLoop.log_info2("#{e.class}: #{e.message}")
      RunLoop.log_info2("The app probably needs to be launched!")
    end
  end

  if relaunch
    launcher.relaunch(options)
  end
end

After("@german") do
  if !xamarin_test_cloud?
    target = ENV["DEVICE_TARGET"] || RunLoop::Core.default_simulator

    simulator = RunLoop::Device.device_with_identifier(target)

    RunLoop::CoreSimulator.erase(simulator)
    RunLoop::CoreSimulator.set_locale(simulator, "en_US")
    RunLoop::CoreSimulator.set_language(simulator, "en-US")
  end
end

After("@port_from_env") do
  if !xamarin_test_cloud?
    calabash_exit
    sleep 1.0
    ENV["DEVICE_ENDPOINT"] = @original_endpoint
  end
end

After do |scenario|
  @no_relaunch = false
  @acquaint_options = nil
  @device_agent_test_app_options = nil
  @skip_embedded_server_options = nil
  @port_from_env_options = nil
  # Calabash can shutdown the app cleanly by calling the app life cycle methods
  # in the UIApplicationDelegate.  This is really nice for CI environments, but
  # not so good for local development.
  #
  # See the documentation for QUIT_APP_AFTER_SCENARIO for a nice debugging workflow
  #
  # http://calabashapi.xamarin.com/ios/file.ENVIRONMENT_VARIABLES.html#label-QUIT_APP_AFTER_SCENARIO
  # http://calabashapi.xamarin.com/ios/Calabash/Cucumber/Core.html#console_attach-instance_method
  if launcher.quit_app_after_scenario?
    calabash_exit
    sleep 1.0
  end
end

