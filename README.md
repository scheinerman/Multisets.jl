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
To delete an element from `M` use `M[x]=0`.


## Access and printing

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

NEED DOCUMENTATION ON `multi_show_short`, `multi_show_braces`, and
`multi_show_julia`.



## Operations
