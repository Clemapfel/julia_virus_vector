module Vi

    using Base64

    # zero width spaces
    const mongolian_vowel = Char(0x180E)
    const zero_width = Char(0x200B)

    # maps digits (0, 1, ..., 9) to ASCII trivially printable characters that are not used by Base64
    const digit_mapping_first_i = 48;#33;
    const digit_mapping = Dict([i-digit_mapping_first_i => Char(i) for i in digit_mapping_first_i:(digit_mapping_first_i + 10)])
    const digit_unmapping = Dict([pair.second => pair.first for pair in Vi.digit_mapping])

    # transform number into their digit mapping
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

    # transform digit mapping to number
    function decode_number(string::String) ::Int64

        current_decimal_i = length(string)-1
        out = 0;
        for c in string
           out += 10^current_decimal_i * digit_unmapping[c]
           current_decimal_i -= 1
        end

        return out;
    end

    # compress a string, replace any sequential repetitions with their number, e.g. AAAAAAA becomes A7
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

    # uncompress the string
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

    # encode a shared library called "..." in the same directory
    function encode(binary_path::String = "...") ::String

        io = IOBuffer();
        pipe = Base64EncodePipe(io);
        write(pipe, open(binary_path))

        as_uint8 = Vector{Char}(take!(io))
        as_uint8 = zip(as_uint8)

        for pair in digit_unmapping
            pushfirst!(as_uint8, pair.first)
        end

        as_binary = Vector{Char}()
        zero = zero_width
        one = mongolian_vowel

        for i in as_uint8
            for b in bitstring(i)
                if b == "0"
                    push!(as_binary, zero);
                else
                    push!(as_binary, one);
                end
            end
        end

        out = open("out.log", "w")
        write(out, String(as_uint8))
        return String(as_binary)
    end
    export encode
end

Vi.encode()