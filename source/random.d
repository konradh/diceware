module random;

import std.stdio : File;
import std.traits : isUnsigned;

/** A random number generator that takes its randomness from /dev/random on linux.
*/
class LinuxRandom(UintType) if (isUnsigned!UintType)
{
    enum isUniformRandom = true;
    enum empty = false;
    enum min = UintType.min;
    enum max = UintType.max;

    private
    {
        UintType value;
        File source;
        ubyte[] buffer;
    }

    this()
    {
        buffer.length = UintType.sizeof;
        source = File("/dev/random", "rb");
        this.popFront();
    }

    void popFront()
    {
        import std.bitmanip : peek;

        source.rawRead(buffer);
        value = buffer.peek!UintType;
    }

    UintType front()
    {
        return value;
    }
}

unittest
{
    import std.range;
    import std.algorithm;
    import std.bitmanip;
    import std.math;

    double chi_squared(ulong[ubyte] observations)
    {
        const N = observations.byValue.sum;
        const p = 1.0 / double(observations.length);
        return observations
            .byValue
            .map!(o => (o - N * p) * (o - N * p) / (N * p))
            .sum;
    }

    auto rand = new LinuxRandom!ulong;
    ulong[ubyte] observations;
    ubyte[] buffer;
    buffer.length = ulong.sizeof;
    rand
        .take(1_000_000)
        .each!((ulong ul) {
            std.bitmanip.write(buffer, ul, 0);
            foreach (b; buffer)
            {
                if (b in observations)
                {
                    observations[b]++;
                }
                else
                {
                    observations[b] = 1;
                }
            }
        });

    const chi2 = chi_squared(observations);
    assert(200 < chi2 && chi2 < 300);
}
