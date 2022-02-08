require_relative "../lib/eavi/visitor"

# An object to JSON serializer example
class Jsonifier
  extend Eavi::Visitor

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

puts Jsonifier.visit({ value: { a: 1, b: "boo" } })
