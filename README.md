# Multisets

Finite multisets in Julia.

A *multiset* is an unordered collection of things with repetition permitted.

## Installation

```julia
Pkg.clone("https://github.com/scheinerman/Multisets.jl.git")
```

## Creating a multiset

```julia
M = Multiset{Type}()
```

If `Type` is omitted, this defaults to `Any`.

Given a collection `list` of elements (such as a `Vector` or `Set`)
invoking `Multiset(list)` creates a new `Multiset` in which the elements
of `list` appear with the appropriate multiplicity. For example,
`Multiset(eye(Int,3))` creates the multiset `{0,0,0,0,0,0,1,1,1}`.


## Adding/deleting elements

+ `push!(M,x)` increases the multiplicity of `x` in `M` by 1. If `x` is not
already in `M`, then it is added to `M`.
+ `push!(M,x,incr)` increases the multiplicity of `x` in `M` by `incr`. We
allow `incr` to be negative to decrease the multiplicity of `x`
(but not below 0).
+ `M[x]=m` explicitly sets the multiplicty of `x` to `m`.
+ `delete!(M,x)` removes `x` from `M`. `M[x]=0` has the same effect.

## Access

To determine the multiplicity of `x` in `M` use `M[x]`. This returns `0`
if `x` was never added to `M`.


To get a list of all the elements in `M`, use `collect`:
```julia
julia> collect(M)
6-element Array{Int64,1}:
 1
 1
 2
 2
 3
 4
```
Notice that elements are repeated per their multiplicity.
To get a list of the elements in which elements appear
only once each use `unique(collect(M))`.

To convert `M` into a Julia `Set` (effectively, set all multiplicities to 1)
use `Set(M)`:
```julia
julia> Set(M)
Set([4,2,3,1])
```

## Printing

The result of `println(M)` can be controlled by the following functions.
Suppose a multiset is created as follows:
```julia
julia> M = Multiset{String}();
julia> push!(M,"alpha");
julia> push!(M,"beta", 2);
```

+ `set_braces_show()()` causes multisets to be printed
as a list enclosed in curly braces:
`{alpha,beta,beta}`. This is the default.
+ `set_short_show()` causes multisets to be printed in an
abbreviated format like this: `Multiset{String} with 3 elements`.
+ `set_julia_show()` causes multisets to be printed in a form that would
be a proper Julia definition of that multiset:
`Multiset(String["alpha","beta","beta"])`.



## Operations

#### Union/Intersection
The functions `union` and `intersect` compute the union and intersection
of multisets. For example:
```julia
julia> A = Multiset(1,2,2,3)
{1,2,2,3}

julia> B = Multiset(1,1,1,2,4)
{1,1,1,2,4}

julia> union(A,B)
{1,1,1,2,2,3,4}

julia> intersect(A,B)
{1,2}
```
The multiplicity of `x` in `union(A,B)` is `max(A[x],B[x])` and
the multiplicity in `intersect(A,B)` is `min(A[x],B[x])`.

#### Product/sum/difference

+ The *Cartesian product* of multisets `A` and `B` is computed with `A*B`.
If `a` is an element of `A` and `b` is an element of `B` then the
multiplicity of `(a,b)` in `A*B` is `A[x]*B[x]`.

+ For a nonnegative integer `n` and a multiset `A` the result of `n*A` is
a new multiset in which the multiplicy of `x` is `n*A[x]`.

+ The *disjoint union* of `A` and `B` is computed with `A+B`.
If `a` is an element of `A` and `b` is an element of `B` then the
multiplicity of `(a,b)` in `A*B` is `A[x]+B[x]`.

+ The *difference* of multisets is computed as `A-B`. In the result,
the multiplicity of `x` is `max(0, A[x]-B[x])`.


#### Cardinality

The function `length` computes the cardinality (number of elements)
in a multiset (including multiplicities).

The function `isempty` returns `true` exactly when `length(M)==0`.

## Comparison

The operator `A==B` and the function `issubset(A,B)` are provided to determine
if two `A` and `B` are equal or `A`is a submultiset of `B`.

Note that `A==B` holds when `A[x]==B[x]` for all `x` and `issubset(A,B)`
holds when `A[x] <= B[x]` for all `x`.

## Miscellaneous

A `Multiset` consists of a single data field called `data` that is a
dictionary mapping elements to their multiplicities. The various
`Multiset` functions ensure the integrity of `data` (enforcing nonnegativity).

The function `clean!` purges the `data` field of any elements with multiplicity
equal to `0`. This is only used by the `hash` function which is provided so
a `Multiset` can be used as a key in a dictionary, etc. The hash of a
`Multiset` is simply the hash of its cleaned `data` field.
