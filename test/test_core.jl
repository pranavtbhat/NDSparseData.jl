using Base.Test
using NDSparseData

let a = Indexes([1,2,1],["foo","bar","baz"]),
    b = Indexes([2,1,1],["bar","baz","foo"]),
    c = Indexes([1,1,2],["foo","baz","bar"])
    @test a != b
    @test a != c
    @test b != c
    @test sort!(a) == sort!(b) == sort!(c)
    @test size(a) == size(b) == size(c) == (3,)
end

let c = Indexes([1,1,1,2,2], [1,2,4,3,5]),
    d = Indexes([1,1,2,2,2], [1,3,1,4,5]),
    e = Indexes([1,1,1], sort([rand(),0.5,rand()])),
    f = Indexes([1,1,1], sort([rand(),0.5,rand()]))
    @test union(c,d) == Indexes([1,1,1,1,2,2,2,2],[1,2,3,4,1,3,4,5])
    @test length(union(e,f).columns[1]) == 5
    @test summary(c) == "Indexes{Tuple{Int64,Int64}}"
end

let c = Indexes([1,1,1,2,2], [1,2,4,3,5]),
    d = Indexes([1,1,2,2,2], [1,3,1,4,5]),
    e = Indexes([1,1,1], sort([rand(),0.5,rand()])),
    f = Indexes([1,1,1], sort([rand(),0.5,rand()]))
    @test intersect(c,d) == Indexes([1,2],[1,5])
    @test length(intersect(e,f).columns[1]) == 1
end

let seed = 123
    srand(seed)
    A = NDSparse((3,6,3,10), rand(1:3,10), rand('A':'F',10), map(UInt8,rand(1:3,10)), collect(1:10), randn(10))
    B = NDSparse((3,6,3), map(UInt8,rand(1:3,10)), rand('A':'F',10), rand(1:3,10), randn(10))
    C = NDSparse((3,3,3), map(UInt8,rand(1:3,10)), rand(1:3,10), rand(1:3,10), randn(10))
    @test isa(A, AbstractArray{Float64,4})
    @test isa(B, AbstractArray{Float64,3})
    @test isa(C, AbstractArray{Float64,3})
    @test size(A) == (3,6,3,10)
    @test size(B) == (3,6,3)
    @test size(C) == (3,3,3)
end 

let a = NDSparse((50,100), [12,21,32], [52,41,34], [11,53,150]),
    b = NDSparse((50,100), [12,23,32], [52,43,34], [56,13,10])
    @test sum(a) == 214

    c = similar(a)
    @test typeof(c) == typeof(a)
    @test length(c.indexes) == 0

    c = similar(a, Float64, (10,10))
    @test eltype(c) === Float64
    @test size(c) == (10,10)
    @test eltype(c.indexes) == eltype(a.indexes)
    @test NDSparseData.dimensions(c.indexes) == NDSparseData.dimensions(a.indexes)

    c = copy(a)
    @test typeof(c) == typeof(a)
    @test length(c.indexes) == length(a.indexes)
    empty!(c)
    @test length(c.indexes) == 0

    c = NDSparseData.convert_dimension(NDSparseData.convert_dimension(a, 1, Dict(12=>10, 21=>20, 32=>20)), 2, Dict(52=>50, 34=>20, 41=>20), -)
    @test c[20,20] == 97

    c = map(+, a, b)
    @test length(c.indexes) == 4
    @test sum(map(-, c, c)) == 0
end

let S = spdiagm(1:5)
    nd = convert(NDSparse, S)
    @test sum(S) == sum(nd) == sum(convert(NDSparse, full(S)))

    @test sum(broadcast(+, 10, nd)) == (sum(nd) + 10*nnz(S))
    @test sum(broadcast(+, nd, 10)) == (sum(nd) + 10*nnz(S))
    @test sum(broadcast(+, nd, nd)) == 2*sum(nd)

    nd[1:5,1:5] = 2
    @test sum(nd[1:5, 1:5]) == 50
end

let a = rand(10), b = rand(10), c = rand(10)
    @test NDSparse((10,10), a, b, c) == NDSparse((10,10), a, b, c)
    c2 = copy(c)
    c2[1] += 1
    @test NDSparse((10,10), a, b, c) != NDSparse((10,10), a, b, c2)
    b2 = copy(b)
    b2[1] += 1
    @test NDSparse((10,10), a, b, c) != NDSparse((10,10), a, b2, c)
end

let a = rand(10), b = rand(10), c = rand(10), d = rand(10)
    @test permutedims(NDSparse((10,10,10), a,b,c,d),[3,1,2]) == NDSparse((10,10,10),c,a,b,d)
end

let r=1:5, s=1:2:5
    A = NDSparse((5,5), [r;], [r;], [r;])
    @test A[s, :] == NDSparse((5,5), [s;], [s;], [s;])
end
