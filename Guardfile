# Project Guard configuration file
# More info at https://github.com/guard/guard#readme

guard :minitest do
  watch %r{^test/(.+\/)*(.+)_test\.rb$} do
    'test'
  end

  watch %r{^test/test_helper\.rb$} do
    'test'
  end

  watch %r{^lib/(.+\/)*(.+)\.rb$} do
    'test'
  end
end
