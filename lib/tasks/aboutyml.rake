require 'about_yml'

check_yml = Gem::Specification.find_by_name 'about_yml'
load "#{check_yml.gem_dir}/lib/about_yml/tasks/check_about_yml.rake"
