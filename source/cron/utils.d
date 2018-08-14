module cron.utils;


private
{
    import std.algorithm : each, map;
    import std.array : array, split;
    import std.conv : to;
    import std.range : iota;
    import std.traits : isSomeString;
    import std.typecons : tuple;
}



void parseList(T, R)(ref T val, R expr)
    if (isSomeString!R)
{
    val = 0;
    expr.split(",")
        .map!(to!ubyte)
        .array
        .each!(n => bitSet!T(val, n));
}


unittest
{
    ushort x;
    parseList(x, "1,2,4,5,8");
    assert(x == cast(ushort)0b100110110);
}


void parseRange(T, R)(ref T val, R expr, ubyte from, ubyte until)
    if (isSomeString!R)
{
    val = 0;
    auto rngs = expr.split("-")
                    .map!(to!ubyte)
                    .array;
    if (rngs.length < 2)
        return;

    if (rngs[0] < rngs[1])
    {
        iota(rngs[0], rngs[1] + 1)
            .each!(n => bitSet!T(val, cast(ubyte)n));
    }
    else
    {
        iota(rngs[0], until + 1)
            .each!(n => bitSet!T(val, cast(ubyte)n));
        iota(from, rngs[1] + 1)
            .each!(n => bitSet!T(val, cast(ubyte)n));
    }
}


unittest
{
    ushort x;
    parseRange(x, "4-7", 1, 10);
    assert(x == cast(ushort)0b_0000_0000_1111_0000);
    parseRange(x, "7-4", 1, 10);
    assert(x == cast(ushort)0b_0000_0111_1001_1110);
}


void parseSequence(T, R)(ref T val, R expr, ubyte from, ubyte until)
    if (isSomeString!R)
{
    val = 0;
    auto rngs = expr.split("/")
                    .map!(n => n == "*" ? from : n.to!ubyte)
                    .array;
    if(rngs.length < 2)
        return;

    iota(rngs[0], until + 1, rngs[1])
        .each!(n => bitSet!T(val, cast(ubyte)n));
}


unittest
{
    ushort x;
    parseSequence(x, "1/3", 1, 10);
    assert(x == cast(ushort)0b_0000_0100_1001_0010);
    parseSequence(x, "*/2", 0, 15);
    assert(x == cast(ushort)0b_0101_0101_0101_0101);
    parseSequence(x, "2/10", 0, 7);
    assert(x == cast(ushort)0b_0000_0000_0000_0100);
}



void parseAny(T)(ref T val, ubyte from, ubyte until)
{
    val = 0;
    iota(from, until + 1)
        .each!(n => bitSet!T(val, cast(ubyte)n));
}


unittest
{
    ushort x;
    parseAny(x, 1, 10);
    assert(x == cast(ushort)0b_0000_0111_1111_1110);
}



bool bitTest(T)(T num, ubyte idx)
{
    return (num & (cast(T)1 << idx)) != 0;
}


void bitSet(T)(ref T num, ubyte idx)
{
    num = cast(T)(num | (cast(T)1 << idx));
}


void bitClear(T)(ref T num, ubyte idx)
{
    num = cast(T)(num & (~(cast(T)1 << idx)));
}


unittest
{
    ulong num = 0x1_00_00;
    assert(bitTest(num, 16));
    bitClear(num, 16);
    assert(!bitTest(num, 16));
    bitSet(num, 63);
    assert(num);
}

