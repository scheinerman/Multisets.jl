using Multisets
using Test

A = Multiset(1:5)
B = A + A
@test length(B) == 2 * length(A)
@test A < B
@test A <= B
@test B > A
@test B >= A
B[1] = 0
@test Set(B) == Set(2:5)
@test length(A | B) == 9
@test length(A & B) == 4
@test length(A * B) == 40
@test length(A + B) == 13
@test collect(A) == collect(1:5)
@test hash(A) != hash(B)

@test Multiset(1, 2, 3, 1) == Multiset([1, 1, 2, 3])
@test eltype(Multiset(1, 2, 3)) == Int
@test Multiset(1.0, 2.0) == Multiset(1 + 0im, big(2))


A = Multiset(1, 1, 1, 2, 1, 3, 3)
@test sum(A) == 12
@test sort(collect(keys(A))) == [1, 2, 3]
@test sort(collect(values(A))) == [1, 2, 4]
@test sort(collect(pairs(A))) == [1 => 4, 2 => 1, 3 => 2]
