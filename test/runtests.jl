using Multisets
using Base.Test

A = Multiset(1:5)
B = A+A
@test length(B)==2*length(A)
@test A<B
@test A<=B
@test B>A
@test B>=A
B[1]=0
@test Set(B)==Set(2:5)
@test length(A|B) == 9
@test length(A&B) == 4
@test length(A*B) == 40
@test length(A+B) == 13
@test collect(A) == collect(1:5)
@test hash(A) != hash(B)
