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
multiplicity of `x` is `max(A[x],B[x])`. This may be invoked as 
`A ∪ B`.
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
`A+B` for multisets is the disjoint union, i.e., a new multiset in which the
multiplicity of `x` is `A[x]+B[x]`. 
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
function _intersect(A::Multiset{S}, B::Multiset{S}) where {S}
    M = Multiset{S}()
    for (x, v) in A.data
        push!(M, x, min(v, B[x]))
    end
    return M
end

"""
`intersect(A,B)` for multisets creates a new multiset in which the
multiplicity of `x` is `min(A[x],B[x])`.
This may be abbreviated `A ∩ B`.
"""
function intersect(A::Multiset{S}, B::Multiset{T}) where {S,T}
    if S == T
        return _intersect(A, B)
    end
    ST = typejoin(S, T)
    AA = type_convert(ST, A)
    BB = type_convert(ST, B)
    return _intersect(AA, BB)
end


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


(==)(A::Multiset, B::Multiset) = (length(A) == length(B)) && issubset(A, B)


## mixing Multisets with other AbstractSets

AnySet = Union{BitSet,Set}

union(A::Multiset, B::T) where {T<:AnySet} = union(A, Multiset(B))
union(B::Set, A::Multiset) = union(A, Multiset(B))
union(B::BitSet, A::Multiset) = union(A, Multiset(B))

intersect(A::Multiset, B::T) where {T<:AnySet} = intersect(A, Multiset(B))
intersect(B::Set, A::Multiset) = intersect(A, Multiset(B))
intersect(B::BitSet, A::Multiset) = intersect(A, Multiset(B))

(+)(A::Multiset, B::T) where {T<:AnySet} = A + Multiset(B)
(+)(B::T, A::Multiset) where {T<:AnySet} = A + Multiset(B)

(-)(A::Multiset, B::T) where {T<:AnySet} = A - Multiset(B)
(-)(B::T, A::Multiset) where {T<:AnySet} = Multiset(B) - A
