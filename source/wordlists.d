module wordlists;

import std.stdio;
import std.array;
import std.algorithm;

struct Wordlist
{
    string name;
    string description;
    string list;
}

enum Wordlist[string] wordlists = [
    "eff_large": Wordlist("eff_large",
        "default EFF list",
        import(
            "eff_large_wordlist.txt")),
    "eff_short_1": Wordlist("eff_short_1",
        "only short words",
        import("eff_short_wordlist_1.txt")),
    "eff_short_2": Wordlist(
        "eff_short_2",
        "words that may be more memorable",
        import("eff_short_wordlist_2_0.txt")),
    "german": Wordlist(
        "german",
        "https://github.com/dys2p/wordlists-de/blob/main/de-7776-v1.txt",
        import("de-7776-v1.txt")
    )
];
