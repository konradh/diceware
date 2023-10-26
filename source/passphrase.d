module passphrase;

import std.algorithm;
import std.array;
import std.conv;
import std.math;
import std.numeric;
import std.random;
import std.range;
import std.stdio;
import std.string;
import std.traits;
import std.typecons;
import std.utf;

import random;

/// Removes all characters from each value of aa for which pred returns false.
dstring[dchar] filterAA(alias pred)(dstring[dchar] aa)
{
    dstring[dchar] output;
    foreach (key, value; aa)
    {
        const auto filtered = value.array
            .filter!pred
            .map!(to!dstring)
            .join;
        if (!filtered.empty)
        {
            output[key] = filtered;
        }
    }
    return output;
}

/// Count the number of elements in r for which pred returns true.
ulong count(alias pred, R)(R r) if (!isInfinite!R)
{
    return r.filter!pred.walkLength;
}

/// All possible leet code subsitutions.
enum dstring[dchar] leetAll = [
    'a': "4@",
    'b': "8",
    'c': "(",
    'd': ")",
    'e': "3",
    'g': "6",
    'i': "1!",
    'j': "]",
    'l': "1|",
    'o': "0",
    'p': "9",
    'q': "9&",
    's': "5$",
    't': "7+",
    'z': "2%",
];

bool isSymbol(dchar c)
{
    import std.uni : isSymbol, isPunctuation;

    return isSymbol(c) || isPunctuation(c);
}

import std.uni : isNumber;

enum leetDigits = filterAA!isNumber(leetAll);
enum leetSymbols = filterAA!isSymbol(leetAll);

/** 
PassphraseGenerator is a generator for Diceware passphrases.

First, configure the properties of the passphrase that should be generated.
Then, call generate() and get your passphrase.

Uses /dev/random as a source of randomness.
*/
struct PassphraseGenerator
{
    private string[] wordlist;
    private LinuxRandom!ulong rand;

    /// Possible types of length requirements.
    enum LengthType
    {
        minimumLength,
        maximumLength,
        minimumEntropy,
        words
    }

    private LengthType lengthType = LengthType.words;
    /// The meaning of length depends on lengthType.
    private ulong length = 6;

    /// The separator to insert between words.
    dstring separator = " ";

    /// Whether to capitalize the individual words.
    Flag!"capitalizeWords" capitalizeWords = No.capitalizeWords;

    /// Try to use this many digits.
    ulong useDigits = 0;

    /// Try to use this many symbols.
    ulong useSymbols = 0;

    /// If there is a possible replacement for a character, use it with this probability. This is ignored if useDigits or useSymbols is not equal to 0.
    double leetProbability = 0;

    this(const string[] words)
    {
        wordlist = words.dup;
        rand = new LinuxRandom!ulong;
    }

    this(const string words)
    {
        wordlist = words.lineSplitter
            .filter!(w => !w.empty)
            .map!(w => w.split.back)
            .array;
        rand = new LinuxRandom!ulong;
    }

    /// Set the number of words to generate.
    void words(ulong count)
    {
        length = count;
        lengthType = LengthType.words;
    }

    /// Set the minimum amount of entropy in bits to include in the passphrase.
    void entropy(ulong bits)
    {
        length = bits;
        lengthType = LengthType.minimumEntropy;
    }

    /// Set the minimum length of the passphrase.
    void minimumLength(ulong characters)
    {
        length = characters;
        lengthType = LengthType.minimumLength;
    }

    /// Set the maximum length of the passphrase.
    void maximumLength(ulong characters)
    {
        length = characters;
        lengthType = LengthType.maximumLength;
    }

    private auto generateWords()
    {
        return std.range.generate(
            () => wordlist.choice(rand).toUTF32);
    }

    private dstring capitalize(dstring word)
    {
        if (capitalizeWords)
        {
            word = word.capitalize();
        }
        return word;
    }

    private dstring[] insertSymbolsAndDigits(const dstring[] _words)
    {
        auto words = _words.dup();

        Tuple!(ulong, ulong)[] findSubstitutionPositions(dstring[] words, dstring[dchar] table)
        {
            return words
                .map!(word => word
                        .enumerate
                        .filter!(character => character.value.toLower in table)
                        .map!(character => character.index)
                        .array)
                .enumerate
                .map!(word =>
                        word.value.map!(i => tuple(word.index, i)))
                .joiner
                .array;
        }

        dstring[] substitute(return dstring[] words, Tuple!(ulong, ulong)[] indices, dstring[dchar] table)
        {
            foreach (pos; indices)
            {
                dchar[] word = words[pos[0]].dup;
                const ch = word[pos[1]].toLower;
                const ar = table[ch];
                word[pos[1]] = ar.array.choice(rand);
                words[pos[0]] = word.dup;
            }
            return words;
        }

        if (useDigits != 0 || useSymbols != 0)
        {
            const nSymbolsExits = words.map!(w => w.count!isSymbol).sum;
            auto symbols = findSubstitutionPositions(words, leetSymbols).array;
            const useSymbols = min(
                max(0, this.useSymbols - nSymbolsExits),
                symbols.length);
            substitute(
                words,
                symbols.randomSample(useSymbols, rand).array,
                leetSymbols);

            const nDigitsExits = words.map!(w => w.count!isNumber).sum;
            auto digits = findSubstitutionPositions(words, leetDigits).array;
            const useDigits = min(
                max(0, this.useDigits - nDigitsExits),
                digits.length);
            substitute(
                words,
                digits.randomSample(useDigits, rand).array,
                leetDigits);

        }
        else if (leetProbability != 0.0)
        {
            auto candidates = findSubstitutionPositions(words, leetAll)
                .filter!(i => uniform(0.0, 1.0, rand) < leetProbability)
                .array;
            substitute(words, candidates, leetAll);
        }
        return words;

    }

    private auto takeNeededWords(Range)(Range r)
    {
        dstring[] words;
        switch (lengthType)
        {
        case LengthType.words:
            words = r.take(length).array;
            break;
        case LengthType.minimumEntropy:
            const wordEntropy = log2(double(wordlist.length));
            const neededWords = (double(length) / wordEntropy).ceil.lrint;
            words = r.take(neededWords).array;
            break;
        case LengthType.minimumLength:
            ulong l = 0;
            foreach (word; r)
            {
                if (l >= length)
                {
                    break;
                }
                l += word.length + (words.empty ? 0 : separator.length);
                words ~= word;
            }
            break;
        case LengthType.maximumLength:
            ulong l = 0;
            foreach (word; r)
            {
                const wouldAddLength = word.length
                    + (words.empty ? 0 : separator.length);
                if (l + wouldAddLength > length)
                {
                    break;
                }
                l += wouldAddLength;
                words ~= word;
            }
            break;
        default:
            assert(false, "unknown lengthType");
        }

        return words;
    }

    /// Generate a passphrase with the previously configured properties.
    string generate()
    {
        auto words = takeNeededWords(generateWords())
            .map!(word => capitalize(word))
            .array;
        words = insertSymbolsAndDigits(words);
        return words.join(separator).toUTF8;
    }
}

///
unittest
{
    import wordlists : wordlists;

    auto generator = PassphraseGenerator(wordlists["eff_large"].list);
    generator.minimumLength(30);
    generator.capitalizeWords = Yes.capitalizeWords;
    generator.generate();
}
