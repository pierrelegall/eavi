# Eavi

Eavi (for Easy Visitor) is a Ruby visitor pattern helper.

You can find [here](https://en.wikipedia.org/wiki/Visitor_pattern) the well documented Wikipedia article about the visitor pattern.

## Benefits

- it **automatically cross the ancestors list (classes in the hierarchy and included modules)** to find a matching visit method (like a statically typed language does thanks to method overloading)
- it **works without polluting visitable objects interface** with an `accept` method (not possible with a statically typed language like `C++` or `Java`); consequently it does not require to explicitly set visited objects visitable
- it allows class instance visitors (when `Eavi::Visitor` is included) and singleton visitors (when `Eavi::Visitor` is extended), all-in-one
- it comes with its own little internal Domain-Specific Language (see code examples below)
- it raises a custom error (`Eavi::NoVisitMethodError`, a subtype of `TypeError`) if a visitor cannot handle an object

## How to use

A visitor can be define like this:

```ruby
class Jsonifier
  include Eavi::Visitor

  visit_for Array do |array|
    # some code…
  end

  visit_for Hash do |hash|
    # some code…
  end

  visit_for String, Fixnum do |string|
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
  extend Eavi::Visitor

  # […]
end

Jsonifier.visit an_object
```

And feel free to **alias the visit method**:

```ruby
module Jsonifier
  extend Eavi::Visitor

  alias_visit :serialize

  serialize_for Array do |array|
    # some code…
  end

  # […]
end

Jsonifier.serialize an_object
```

## Benchmark

This is a benchmark output (with Ruby 2.3):

> This benchmark compare the speed of a visit call and a standard method call.
>
> Benchmarking…
>
> - Average at depth 0:    4.09x slower
> - Average at depth 3:    8.03x slower
> - Average when extended: 5.84x slower
> - Average when included: 6.28x slower
> - Total average:         6.06x slower

The **depth** is the number of tries before matching an existing visit method using the visited object's ancestors' list.

This benchmark shows that a visit method call is **on average only 6x slower** than a standard method call.

## License

Eavi is licensed under the MIT License.
