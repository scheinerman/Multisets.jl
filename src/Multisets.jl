module Multisets

export Multiset

"""
A `Multiset` is an unordered collection of things with repetition permitted.
A new `Multiset` container is created with `Multiset{T}()` where `T` is the
type of the objects held in the multiset. If `T` is omitted, it defaults
to `Any`.
"""
type Multiset{T}
  data::Dict{T,Int}
  function Multiset()
    d = Dict{T,Int}()
    new(d)
  end
end

Multiset() = Multiset{Any}()


end #end of Module
