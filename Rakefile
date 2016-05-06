namespace :generate do
  task :doc do
    sh %{rdoc --ri}
  end
end

namespace :run do
  task :test do
    Dir.glob("./test/**/*_test.rb") do |test|
      require_relative test
    end
  end

  task :benchmark do
    Dir.glob("./benchmark/**/*_benchmark.rb") do |benchmark|
      require_relative benchmark
    end
  end
end

namespace :clean do
  task :all => [:doc]
  task :doc do
    sh %{rm -rf doc/}
  end
end
