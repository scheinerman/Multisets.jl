# enable iteration for Multisets

import Base.iterate

# In iterating in a multiset, we should see each element repeatedly 
# corresponding to its multiplicity in the multiset.

# We bulid a complicated state as follows:
# ss = (val, k, next)
# val is the val we returned
# k is the number of times we returned val 
# next is the state returned by iterate on M.data


function iterate(M::Multiset, ss)
    val, k, s = ss
    if k < M[val]
        return (val, (val, k + 1, s))
    end

    result = iterate(M.data, s)
    if isnothing(result)
        return nothing
    end
    pr, st = result
    val = pr[1]
    return (val, (val, 1, st))
end


function iterate(M::Multiset)
    clean!(M)  # get rid of all multiplicity zero items (if any)
    result = iterate(M.data)
    if isnothing(result)
        return nothing
    end
    pr, st = result   # this is what iterate(M.data) gave us
    val = pr[1]
    return (val, (val, 1, st))
end
