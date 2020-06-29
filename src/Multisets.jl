module Multisets

import Base: show, length, getindex, collect, union, intersect, isempty, first
import Base: push!, setindex!, delete!, hash
import Base: (*), (+), (-), (|), (&)
import Base: issubset, Set, (==), (<), (<=), (>), (>=)


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
struct Multiset{T}
    data::Dict{T,Int}
    function Multiset{T}() where {T}
        d = Dict{T,Int}()
        new(d)
    end
end
Multiset() = Multiset{Any}()

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
multi_show_flag = multi_show_braces



"""
Set show display mode for multisets, like this:

`Multiset{Int64} with 7 elements`

See also `set_braces_show` and `set_julia_show`.
"""
set_short_show() = (global multi_show_flag = multi_show_short; nothing)

"""
Set braces display mode for multisets, like this:

`{1,2,2,3,3,3,3}`

See also `set_short_show` and `set_julia_show`.
"""
set_braces_show() = (global multi_show_flag = multi_show_braces; nothing)


"""
Set Julia style display mode for multisets, like this:

`Multiset(Int64[1,2,2,3,3,3,3])`

See also `set_short_show` and `set_braces_show`.
"""
set_julia_show() = (global multi_show_flag = multi_show_julia; nothing)

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


# private helper for union
function _union(A::Multiset{S}, B::Multiset{S}) where {S}
    M = Multiset{S}()
    for (x, v) in A.data
        M[x] = max(v, B[x])
    end
    for (y, w) in B.data
        M[y] = max(A[y], w)
    end
    return M
end

function type_convert(T, A::Multiset)
    M = Multiset{T}()
    for (x, v) in A.data
        xx = convert(T, x)
        M[xx] = v
    end
    return M
end


"""
`union(A,B)` for multisets creates a new multiset in which the
multiplicity of `x` is `max(A[x],B[x])`.
"""
function union(A::Multiset{S}, B::Multiset{T}) where {S,T}
    if S == T
        return _union(A, B)
    end
    ST = typejoin(S, T)
    AA = type_convert(ST, A)
    BB = type_convert(ST, B)
    return _union(AA, BB)
end


"""
For multisets, `A|B` is `union(A,B)`. See also `+` which behaves differently.
"""
(|)(A::Multiset, B::Multiset) = union(A, B)

"""
`A+B` for multisets is the disjoint union, i.e., a new multiset in which the
multiplicity of `x` is `A[x]+B[x]`. This can be abbreviated `A|B`.
"""
function (+)(A::Multiset{S}, B::Multiset{T}) where {S,T}
    ST = typejoin(S, T)
    M = Multiset{ST}()
    for (x, v) in A.data
        push!(M, x, v)
    end
    for (x, v) in B.data
        push!(M, x, v)
    end
    return M
end

# private helper for A-B
function _minus(A::Multiset{S}, B::Multiset{S}) where {S}
    M = Multiset{S}()
    for (x, v) in A.data
        M.data[x] = max(v - B[x], 0)
    end
    return M
end

"""
`A-B` for multisets is the multiset difference, i.e., a new multiset
in which the multiplicity of `x` is `A[x]-B[x]` unless this goes
below `0`, in which case the multiplicity is 0.
"""
function (-)(A::Multiset{S}, B::Multiset{T}) where {S,T}
    if S == T
        return _minus(A, B)
    end
    ST = typejoin(S, T)
    AA = type_convert(ST, A)
    BB = type_convert(ST, B)
    return _minus(AA, BB)
end

# private helper for intersect
function _inter(A::Multiset{S}, B::Multiset{S}) where {S}
    M = Multiset{S}()
    for (x, v) in A.data
        push!(M, x, min(v, B[x]))
    end
    return M
end

"""
`intersect(A,B)` for multisets creates a new multiset in which the
multiplicity of `x` is `min(A[x],B[x])`.
This may be abbreviated `A&B`.
"""
function intersect(A::Multiset{S}, B::Multiset{T}) where {S,T}
    if S == T
        return _inter(A, B)
    end
    ST = typejoin(S, T)
    AA = type_convert(ST, A)
    BB = type_convert(ST, B)
    return _inter(AA, BB)
end

"""
`A&B` for multisets is `intersect(A,B)`.
"""
(&)(A::Multiset, B::Multiset) = intersect(A, B)

"""
`A*B` for the Cartesian product of multisets `A` and `B`.
"""
function (*)(A::Multiset{S}, B::Multiset{T}) where {S,T}
    ST = Tuple{S,T}
    M = Multiset{ST}()
    for (a, v) in A.data
        for (b, w) in B.data
            M.data[(a, b)] = v * w
        end
    end
    return M
end

"""
`n*A` is the scalar multiple of a multiset in which the multiplicity of
`x` is `n*A[x]`. Of course, we require `n >= 0`.
"""
function (*)(n::Int, A::Multiset{T}) where {T}
    @assert n >= 0 "Scalar multiplication of a multiset must be by a nonnegative integer"
    M = Multiset{T}()
    for (x, v) in A.data
        M.data[x] = n * v
    end
    return M
end

# private helper for issubset
function _sub(A::Multiset{S}, B::Multiset{S}) where {S}
    for (x, v) in A.data
        if v > B[x]
            return false
        end
    end
    return true
end

function issubset(A::Multiset{S}, B::Multiset{T}) where {S,T}
    if S == T
        return _sub(A, B)
    end
    ST = typejoin(S, T)
    AA = type_convert(ST, A)
    BB = type_convert(ST, B)
    return _sub(AA, BB)
end

(<=)(A::Multiset, B::Multiset) = issubset(A, B)
(<)(A::Multiset, B::Multiset) = (length(A) < length(B)) && (A <= B)
(>)(A::Multiset, B::Multiset) = B < A
(>=)(A::Multiset, B::Multiset) = B <= A

(==)(A::Multiset, B::Multiset) = (length(A) == length(B)) && issubset(A, B)

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



end #end of Module
