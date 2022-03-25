
module Vi

    using Base64

    const mongolian_vowel = Char(0x180E)
    const zero_width = Char(0x200B)
    const zero_width_nb = Char(0xFEFF)
    const thin = Char(0x2009)
    const hair = Char(0x200A)
    const carriage_return = Char(0x0D)

    const digit_mapping_first_i = 48;#33;
    const digit_mapping = Dict([i-digit_mapping_first_i => Char(i) for i in digit_mapping_first_i:(digit_mapping_first_i + 10)])
    const digit_unmapping = Dict([pair.second => pair.first for pair in Vi.digit_mapping])

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

    function zip(input::Vector{Char}) ::Vector{Char}

        out = Vector{Char}()
        sizehint!(out, length(input))

        origin_i = 1
        while origin_i <= length(input)

            current = input[origin_i]
            push!(out, current)

            count = 0
            while origin_i+1 < length(input) && input[origin_i+1] == current
                count += 1
                origin_i += 1
            end

            if count > 2
                number = encode_number(count)
                for c in number
                    push!(out, c)
                end
            end

           origin_i += 1
        end

        return out
    end

    function unzip(str_in::Vector{Char}) ::Vector{Char}

        out = Vector{Char}()

        i = 1
        while i <= length(str_in)

            current = str_in[i]
            count = 1
            offset = 1
            if haskey(digit_unmapping, current)
                number = string(current)
                while haskey(digit_unmapping, str_in[i+offset])
                    number *= string(str_in[i+offset])
                    offset += 1
                end
                count = decode_number(number)
            end

            if (count > 1)
                for _ in 1:count
                    push!(out, str_in[i - 1])
                end
            else
                push!(out, current)
            end

            i += offset;
        end

        return out
    end


    function encode(binary_path::String = "...") ::String

        io = IOBuffer();
        pipe = Base64EncodePipe(io);
        write(pipe, open(binary_path))

        as_uint8 = Vector{Char}(take!(io))

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

str = "AAAAAAAAABCDEFGHIJKLMNOPPPPPPQRSTUUUUV"
zipped = zip([i for i in str])
unzipped = unzip(zipped);
println(str)
println(String(zipped))
println(String(unzipped))

end
