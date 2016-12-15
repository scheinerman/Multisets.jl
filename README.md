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

## Adding/deleting elements to a multiset 
