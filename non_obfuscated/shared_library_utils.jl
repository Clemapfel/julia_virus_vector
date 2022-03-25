
module Vi

    using Base64

    const mongolian_vowel = Char(0x180E)
    const zero_width = Char(0x200B)
    const zero_width_nb = Char(0xFEFF)
    const thin = Char(0x2009)
    const hair = Char(0x200A)
    const carriage_return = Char(0x0D)

    const digit_mapping = Dict([

        0 => Char(33),
        1 => Char(34),
        2 => Char(35),
        3 => Char(36),
        4 => Char(37),
        5 => Char(38),
        6 => Char(39),
        7 => Char(40),
        8 => Char(41),
        9 => Char(42)
    ]);

    const digit_unmapping = Dict(collect(pair.second => pair.first for pair in Vi.digit_mapping))

    function encode_number(count::Int64) ::String

        max = 1;
        while 10^max < count
            max += 1
        end

        out = Vector{Char}()
        for i in max:-1:1
            push!(out, digit_mapping[trunc(count % 10^i / 10^(i-1))])
        end

        return String(out);
    end

    function decode_number(string::String) ::Int64

        current_decimal_i = length(string)-1
        out = 0;
        for c in string
           out += 10^current_decimal_i * digit_unmapping[c]
           current_decimal_i -= 1
        end

        return out;
    end


    function encode(binary_path::String = "...") ::String

        io = IOBuffer();
        pipe = Base64EncodePipe(io);
        write(pipe, open(binary_path))

        as_uint8 = Vector{UInt8}(take!(io))

        encoded = Vector{Char}()
        zero = zero_width
        one = mongolian_vowel

        # histogram
        hist = Vector{Int64}();
        for i in 1:256
            push!(hist, 0)
        end

        for i in as_uint8
            setindex!(hist, getindex(hist, i) + 1, i)
        end

        res = Vector{Pair{Char, Int64}}()
        for i in 1:length(hist)
            if hist[i] != 0
                push!(res, Char(i) => hist[i])
            end
        end

        for r in res
            println(convert(UInt8, r.first), ": ", r)
        end

        return ""

        for i in as_uint8
            for b in bitstring(i)
                if b == "0"
                    push!(encoded, zero);
                else
                    push!(encoded, one);
                end
            end
        end

        out = open("out.log", "w")
        return String(as_uint8)
    end

    function decode()
end

#println(Vi.encode())
n = 1234567890
println(n)
println(Vi.encode_number(n))
println(Vi.decode_number(encode_number(n)))

end
