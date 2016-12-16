module Multisets

import Base.show, Base.length, Base.getindex, Base.collect
import Base.push!, Base.setindex!


export Multiset, set_short_show, set_julia_show, set_braces_show

"""
A `Multiset` is an unordered collection of things with repetition permitted.
A new `Multiset` container is created with `Multiset{T}()` where `T` is the
type of the objects held in the multiset. If `T` is omitted, it defaults
to `Any`.

A `Multiset` can be created from a collection `list` (such as a `Vector` or
`Set`) with `Multiset(list)`. If an element is repeated in `list` it has
the appropriate multiplicity.
"""
type Multiset{T}
  data::Dict{T,Int}
  function Multiset()
    d = Dict{T,Int}()
    new(d)
  end
end
Multiset() = Multiset{Any}()

function Multiset{T,d}(list::AbstractArray{T,d})
  M = Multiset{T}()
  for x in list
    push!(M,x)
  end
  return M
end

function Multiset{T}(A::Base.AbstractSet{T})
  M = Multiset{T}()
  for x in A
    push!(M,x)
  end
  return M
end

function Multiset{T}(items::T...)
  M = Multiset{T}()
  for x in items
    push!(M,x)
  end
  return M
end


"""
For a `M[t]` where `M` is a `Multiset` returns the
multiplicity of `t` in `M`. A value of `0` means that
`t` is not a member of `M`.
"""
function getindex{T}(M::Multiset{T}, x::T)::Int
  if haskey(M.data,x)
    return M.data[x]
  end
  return 0
end

function push!{T}(M::Multiset{T}, x::T, incr::Int=1)::Multiset{T}
  if haskey(M.data,x)
    M.data[x] += incr
  else
    M.data[x] = incr
  end
  if M.data[x] < 0
    M.data[x]=0
  end
  return M
end

function setindex!{T}(M::Multiset{T}, m::Int, x::T)
  @assert m>=0 "Multiplicity must be nonnegative"
  M.data[x] = m
end

function length(M::Multiset)
  total = 0
  for v in values(M.data)
    total += v
  end
  return total
end

function collect{T}(M::Multiset{T})
  n = length(M)
  result = Vector{T}(n)
  i = 0
  for (k,v) in M.data
    for _=1:v
      i += 1
      result[i] = k
    end
  end
  try
    sort!(result)
  end
  return result
end

function braces_string{T}(M::Multiset{T})
  elts = collect(M)
  n = length(elts)
  str = "{"
  for k=1:n
    str *= string(elts[k])
    if k<n
      str *= ","
    end
  end
  str *= "}"
  return str
end

short_string{T}(M::Multiset{T}) = "Multiset{$T} with $(length(M)) elements"

function julia_string{T}(M::Multiset{T})
  elts = collect(M)
  n = length(elts)
  str = "Multiset($T["
  for k=1:n
    str *= string(elts[k])
    if k<n
      str *= ","
    end
  end
  str *= "])"
  return str
end


# This variable controls printing:
# 0 -- {x,y,z}
# 1 -- Multiset{T} with n elements
# 2--  Multiset{T}(x,y,z)

multi_show_braces = 0
multi_show_short  = 1
multi_show_julia  = 2
multi_show_flag = multi_show_braces




set_short_show() = (global multi_show_flag = multi_show_short; nothing)
set_braces_show() = (global multi_show_flag = multi_show_braces; nothing)
set_julia_show()  = (global multi_show_flag = multi_show_julia; nothing)

function show(io::IO, M::Multiset)
  if multi_show_flag == multi_show_short
    print(io, short_string(M))
  end
  if multi_show_flag == multi_show_braces
    print(io, braces_string(M))
  end
  if multi_show_flag == multi_show_julia
    print(io, julia_string(M))
  end
end


end #end of Module
