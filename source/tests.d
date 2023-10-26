module tests;

import std.range;
import std.format;

import passphrase;

static immutable wordlist1 = ["abc"];

unittest
{
    auto g = PassphraseGenerator(wordlist1);

    foreach (t; [[0, 0], [1, 3], [2, 3], [3, 3], [4, 7], [5, 7], [6, 7], [7, 7]])
    {
        g.minimumLength = t[0];
        assert(g.generate.length == t[1], format("minimum length %d", t[1]));
    }

    foreach (t; [[0, 0], [1, 0], [2, 0], [3, 3], [4, 3], [5, 3], [6, 3], [7, 7]])
    {
        g.maximumLength = t[0];
        assert(g.generate.length == t[1], format("maximum length %d", t[1]));
    }
}
