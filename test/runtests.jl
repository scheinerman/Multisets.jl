using Multisets
using Base.Test

# write your own tests here
A = Multiset(1:5)
B = A+A
@test length(B)==2*length(A)
@test A<B
B[1]=0
@test Set(B)==Set(2:5)
