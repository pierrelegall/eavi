# Eavi

Eavi (for Easy Visitor) is a Ruby visitor pattern helper.

You can find [here](https://en.wikipedia.org/wiki/Visitor_pattern) the well documented Wikipedia article about the visitor pattern.

## Benefits

- it **cross the ancestors list (classes and modules in the hierarchy)** to find an associated visit method (like overloading in some statically typed language)
- it **works without polluting visitable objects interface** with an `accept` method; consequently all objects are visitable
- it allows visitors as class instances (when `Eavi::Visitor` is included) and visitors as modules (when `Eavi::Visitor` is extended), all-in-one gem
- it comes with an explicit API, let's call it a DSL (see code examples below)
- it raises a custom error (`Eavi::NoVisitMethodError`, a subtype of `TypeError`) if a visitor cannot handle an object

## How to use

A visitor can be defined like this:

```ruby
# An object to JSON serializer example
class Jsonifier
  include Eavi::Visitor

  def_visit String do |object|
    %!"#{object}"!
  end

  def_visit Integer, Float do |object|
    object.to_s
  end

  def_visit Array do |array|
    "[" + array.map { |e| visit(e) }.join(",") + "]"
  end

  def_visit Hash do |hash|
    "{" + hash.map do |key, value|
      visit(key, as: String) + ":" + visit(value)
    end.join(",") + "}"
  end
end

jsonifier = Jsonifier.new
jsonifier.visit("foo")                         #=> '"foo"'
jsonifier.visit(5)                             #=> '5'
jsonifier.visit(7.5)                           #=> '7.5'
jsonifier.visit([1, 2.5, "bar"])               #=> '[1,2.5,"bar"]'
jsonifier.visit({ a: 3, b: 4.5, c: "baz" })    #=> '{"a":3,"b":4.5,"c":"baz"}'
jsonifier.visit({ value: { a: 1, b: "boo" } }) #=> '{"value":{"a":1,"b":"boo"}}'

jsonifier.visit(/this is a cool gem/)
#=> raises "no visit method in #<Jsonifier:...> for Regexp instances (Eavi::NoVisitMethodError)"
```

You can **build a visitor module/class** too, using `extend` instead of `include`:

```ruby
module Jsonifier
  extend Eavi::Visitor

  # […]
end

Jsonifier.visit(an_object)
```

And feel free to **alias the visit method**:

```ruby
module Jsonifier
  extend Eavi::Visitor

  alias_visit_method :serialize

  # […]
end

Jsonifier.serialize(an_object)
```

## Benchmark

This is a benchmark output (MRI 3.0.3p157, i7-7500U CPU @ 2.70GHz):

> This benchmark compare the speed of a visit call and a standard method call.
>
> Benchmarking…
>
> - Average at depth 0:    22.38x slower
> - Average at depth 3:    56.66x slower
> - Average when extended: 38.21x slower
> - Average when included: 40.83x slower
> - Global average:        39.52x slower

The **depth** is the number of digs before matching an existing visit method using the visited object's ancestors' list.

This benchmark shows that a visit method call is **on average 40x slower** than a standard method call (the call only, not the body of the method).

The benchmark is located in the `benchmark` folder and can be run with `rake run:benchmark`.

## License

Eavi is licensed under the MIT License.
