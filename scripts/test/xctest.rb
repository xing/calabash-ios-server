#!/usr/bin/env ruby
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test-helpers'))

working_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))

xcpretty_available = `gem list xcpretty -i`.chomp == 'true'

XCODE_MAJOR_VERSION=`xcrun -k xcodebuild -version | tr -d "\n" | cut -c 7`.chomp
if XCODE_MAJOR_VERSION == '5'
  target_simulator_name = 'iPhone Retina (4-inch)'
else
  target_simulator_name = 'iPhone 5s'
end

args =
      [
            'clean',
            'test',
            '-SYMROOT=build',
            '-derivedDataPath build',
            '-project calabash.xcodeproj',
            '-scheme calabash-ios-server-tests',
            "-destination 'platform=iOS Simulator,name=#{target_simulator_name},OS=latest'",
            '-sdk iphonesimulator',
            '-configuration Debug',
            xcpretty_available ? '| xcpretty -tc && exit ${PIPESTATUS[0]}' : ''
      ]

Dir.chdir(working_dir) do
  terminate_all_sims
  cmd = "xcrun xcodebuild #{args.join(' ')}"
  do_system(cmd,
            {:pass_msg => 'XCTests passed',
             :fail_msg => 'XCTests failed'})
end
