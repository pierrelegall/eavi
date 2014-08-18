task :doc do
  sh %{rdoc --all --one-file}
end

namespace :run do
  task :spec do
    sh %{rspec spec/visitor_pattern_spec.rb --color}
  end
end

namespace :clean do
  task :all => [:doc]
  task :doc do
    sh %{rm -rf doc/}
  end
end
