require 'reek/rake/task'

Reek::Rake::Task.new do |t|
  t.fail_on_error = false
  t.config_file = 'config.reek'
end
