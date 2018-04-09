
Then(/^I can set the LPServer port with an env var$/) do
  launch_options = launcher.launch_args
  expected = launch_options[:env]["LPF_SERVER_PORT"]
  actual = server_version["server_port"]
  expect(actual).to be == expected
end
