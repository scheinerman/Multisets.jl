module Multisets

import Base: show, length, getindex, collect, union, intersect, isempty, first
import Base: push!, setindex!, delete!, hash, eltype
import Base: (*), (+), (-)
import Base: issubset, Set, (==)


export Multiset, set_short_show, set_julia_show, set_braces_show, set_key_value_show

"""
A `Multiset` is an unordered collection of things with repetition permitted.
A new `Multiset` container is created with `Multiset{T}()` where `T` is the
type of the objects held in the multiset. If `T` is omitted, it defaults
to `Any`.

A `Multiset` can be created from a collection `list` (such as a `Vector` or
`Set`) with `Multiset(list)`. If an element is repeated in `list` it has
the appropriate multiplicity.
"""
struct Multiset{T} <: AbstractSet{T}
    data::Dict{T,Int}
    function Multiset{T}() where {T}
        d = Dict{T,Int}()
        new(d)
    end
end
Multiset() = Multiset{Any}()
Multiset(x...) = Multiset(collect(x))

function Base.copy(M::Multiset{T}) where {T}
    newMultiset = Multiset{T}()
    for (key, value) in pairs(M)
        newMultiset[key] = value
    end
    return newMultiset
end

function Base.empty!(M::Multiset{T}) where {T}
    for (key, value) in pairs(M)
        M[key] = value
    end
    clean!(M)
    return M
end

eltype(M::Multiset{T}) where {T} = T

function Multiset(list::AbstractArray{T,d}) where {T,d}
    M = Multiset{T}()
    for x in list
        push!(M, x)
    end
    return M
end

function Multiset(A::Base.AbstractSet{T}) where {T}
    M = Multiset{T}()
    for x in A
        push!(M, x)
    end
    return M
end

"""
`clean!(M)` removes elements of multiplicy 0 from the underlying data
structure supporting `M`.
"""
function clean!(M::Multiset)
    for x in keys(M.data)
        if M[x] == 0
            delete!(M.data, x)
        end
    end
    nothing
end


"""
For a `M[t]` where `M` is a `Multiset` returns the
multiplicity of `t` in `M`. A value of `0` means that
`t` is not a member of `M`.
"""
function getindex(M::Multiset{T}, x)::Int where {T}
    if haskey(M.data, x)
        return M.data[x]
    end
    return 0
end

"""
`push!(M,x,incr)` increases the multiplicity of `x` in `M`
by `incr` (which defaults to 1). `incr` can be negative, but
it is not possible to decrease the multiplicty below 0.
"""
function push!(M::Multiset{T}, x, incr::Int = 1) where {T}
    if haskey(M.data, x)
        M.data[x] += incr
    else
        M.data[x] = incr
    end
    if M.data[x] < 0
        M.data[x] = 0
    end
    return M
end

function setindex!(M::Multiset{T}, m::Int, x) where {T}
    mm = max(m, 0)
    M.data[x] = mm
    return mm
end

function delete!(M::Multiset, x)
    if haskey(M.data, x)
        delete!(M.data, x)
    end
    return M
end

function length(M::Multiset)
    total = 0
    for v in values(M.data)
        total += v
    end
    return total
end

isempty(M::Multiset) = length(M) == 0

function collect(M::Multiset{T}) where {T}
    n = length(M)
    result = Array{T,1}(undef, n)   #  Vector{T}(n)
    i = 0
    for (k, v) in M.data
        for _ = 1:v
            i += 1
            result[i] = k
        end
    end
    try
        sort!(result)
    catch
    end
    return result
end

function braces_string(M::Multiset{T}) where {T}
    elts = collect(M)
    n = length(elts)
    if n == 0
        return "∅"
    end
    str = "{"
    for k = 1:n
        str *= string(elts[k])
        if k < n
            str *= ","
        end
    end
    str *= "}"
    return str
end

short_string(M::Multiset{T}) where {T} = "Multiset{$T} with $(length(M)) elements"

key_value_string(M::Multiset{T}) where {T} = "Multiset{$T}($(mapreduce(string, (l,r) -> l == "" ? r : l*", "*r, pairs(M), init="")))"


function julia_string(M::Multiset{T}) where {T}
    elts = collect(M)
    n = length(elts)
    str = "Multiset($T["
    q = ""
    if T <: AbstractString
        q = "\""
    end
    for k = 1:n
        str *= q * string(elts[k]) * q
        if k < n
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

const multi_show_braces = 0
const multi_show_short = 1
const multi_show_julia = 2
const multi_show_key_count = 3
multi_show_flag = multi_show_braces



"""
Set show display mode for multisets, like this:

`Multiset{Int64} with 7 elements`

See also `set_braces_show`,`set_key_value_show` and `set_julia_show`.
"""
set_short_show() = (global multi_show_flag = multi_show_short; nothing)

"""
Set braces display mode for multisets, like this:

`{1,2,2,3,3,3,3}`

See also `set_short_show`, `set_key_value_show` and `set_julia_show`.
"""
set_braces_show() = (global multi_show_flag = multi_show_braces; nothing)


"""
Set Julia style display mode for multisets, like this:

`Multiset(Int64[1,2,2,3,3,3,3])`

See also `set_short_show`, `set_key_value_show` and `set_braces_show`.
"""
set_julia_show() = (global multi_show_flag = multi_show_julia; nothing)

"""
Set key-count style display mode for multisets, like this:

`Multiset{Int64}(1 => 1, 2 => 2, 3 => 4)`

See also `set_short_show`, `set_julia_show` and `set_braces_show`.
"""
set_key_value_show() = (global multi_show_flag = multi_show_key_count; nothing)

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
    if multi_show_flag == multi_show_key_count 
        print(io, key_value_string(M))
    end 
end

show(M::Multiset) = show(stdout, M)
import Base.Multimedia.display
display(M::Multiset) = print(string(M))



function hash(M::Multiset, h::UInt = UInt(0))
    clean!(M)
    return hash(M.data, h)
end


function Set(M::Multiset{T}) where {T}
    iter = (x for x in keys(M.data) if M.data[x] > 0)
    return Set{T}(iter)
end

function first(M::Multiset{T})::T where {T}
    if length(M) == 0
        error("Multiset must be nonempty")
    end
    clean!(M)
    return first(first(M.data))
end

include("iter.jl")
include("operations.jl")


import Base: keys, values, pairs


function keys(M::Multiset{T}) where {T}
    clean!(M)
    return keys(M.data)
end

function values(M::Multiset{T}) where {T}
    clean!(M)
    return values(M.data)
end

function pairs(M::Multiset{T}) where {T}
    clean!(M)
    return pairs(M.data)
end

end #end of Module
