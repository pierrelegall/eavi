# Risitor

Risitor is a **R**uby v**isitor** pattern helper.

You can find [here](https://en.wikipedia.org/wiki/Visitor_pattern) the well documented Wikipedia article about the visitor pattern.

## Benefits

- it **automatically cross the ancestors list** to find a matching visit method (like a statically typed language does thanks to method overloading)
- it **works without polluting visitable objects interface** with an `accept` method (not possible with a statically typed language like `C++` or `Java`)
- it does not require to explicitly set visited objects visitable
- it can build class instance visitor (when `Risitor::Base` is included) and singleton visitor (when `Risitor::Base` is extended), all-in-one
- it raise a custom error (`Risitor::NoVisitMethodError`, a subtype of `NoMethodError`) if no visit method match the object type

## How to use

A visitor can be define like this:

```ruby
class Jsonifier
  include Risitor::Base

  when_visiting Array do |array|
    # some code…
  end

  when_visiting Hash do |hash|
    # some code…
  end

  when_visiting String, Fixnum do |string|
    # some code…
  end

  # […]
end

jsonifier = Jsonifier.new
jsonifier.visit an_object
```

You can **build a singleton visitor** too, using `extend` instead of `include`:

```ruby
module Jsonifier
  extend Risitor::Base

  # […]
end

Jsonifier.visit an_object
```

And feel free to **alias the visit method**:

```ruby
module Jsonifier
  extend Risitor::Base

  alias_visit_method :serialize

  # […]
end

Jsonifier.serialize an_object
```

## Benchmark

This is a benchmark output:

> This benchmark compare the speed of a visit call and a standard method call.
>
> Benchmarking…
>
> - Average at depth 0:    4.09x slower
> - Average at depth 3:    8.03x slower
> - Average when extended: 5.84x slower
> - Average when included: 6.28x slower
> - Total average:         6.06x slower

A visit method call is **on average only 6x slower** than a standard method call.

The **depth** is the number of try before matching a visit method crossing the visited object class ancestors.

## License

Risitor is licensed under the MIT License.
