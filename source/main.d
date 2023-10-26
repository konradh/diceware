module main;

import std.algorithm;
import std.range;
import std.stdio;
import std.conv;

import argparse;

import passphrase;
import wordlists : wordlists;

struct Arguments
{
	@(NamedArgument(["number", "c"])
			.Description("Number of passphrases to generate")
			.Placeholder("N"))
	ulong number = 1;

	@(ArgumentGroup("Wordlist selection"))
	{
		@(NamedArgument(["wordlist", "w"])
				.Description("Use a built-in wordlist")
				.AllowedValues!(wordlists.keys))
		string wordlist = "eff_large";

		@(NamedArgument("read-wordlist", "r")
				.Description("Read in and use a wordlist")
				.Placeholder("FILENAME")
		)
		string externalWordlist = "";
	}

	@(ArgumentGroup("Passphrase length requirements")
			.Description("Generate a passphrase that has..."))
	@(MutuallyExclusive())
	{
		@(NamedArgument(["entropy", "e"])
				.Description("at least this number of bits of entropy")
				.Placeholder("BITS"))
		ulong entropy;
		@(NamedArgument(["min-length", "l"])
				.Description("at least this many characters")
				.Placeholder("LENGTH"))
		ulong minLength;
		@(NamedArgument(["max-length", "L"])
				.Description("at most this many characters")
				.Placeholder("LENGTH"))
		ulong maxLength;
		@(NamedArgument(["words", "n"])
				.Description(
					"exactly this many words. --words=6 is the default.")
				.Placeholder("WORDS"))
		ulong words;
	}

	@(ArgumentGroup("Passphrase modifications")
			.Description("Change the passphrase in some way"))
	{
		@(NamedArgument(["capitalize", "C"])
				.Description("Capitalize the individual words"))
		bool capitalize = false;
		@(NamedArgument(["digits", "d"])
				.Description("Try to include this many digits")
				.Placeholder("N"))
		ulong digits = 0;
		@(NamedArgument(["symbols", "s"])
				.Description("Try to include this many symbols")
				.Placeholder("N"))
		ulong symbols = 0;
		@(NamedArgument(["leet-probability", "leet"])
				.Description("Replace characters with 1337 versions with this probability."
					~ "Has no effect if --digits or --symbols is given")
				.Placeholder("PROBABILITY")
		)
		double leetProbability = 0.0;
		@(NamedArgument(["separator", "sep"])
				.Description("Use this to separate words (default is ' ')")
				.Placeholder("CHARACTER"))
		dstring separator = " ";
	}
}

int main(string[] argv)
{
	Arguments args;
	if (!CLI!Arguments.parseArgs(args, argv[1 .. $]))
	{
		return 1;
	}

	string wordlist;
	if (!args.externalWordlist.empty)
	{
		import std.file;

		try
		{
			wordlist = File(args.externalWordlist, "r").byLine(Yes.keepTerminator)
				.join.dup;
		}
		catch (Exception e)
		{
			e.message.writeln;
			return 1;
		}
	}
	else
	{
		wordlist = wordlists[args.wordlist].list;
	}

	auto generator = PassphraseGenerator(wordlist);
	if (args.entropy != 0)
	{
		generator.entropy(args.entropy);
	}
	else if (args.minLength != 0)
	{
		generator.minimumLength(args.minLength);
	}
	else if (args.maxLength != 0)
	{
		generator.maximumLength(args.maxLength);
	}
	else if (args.words != 0)
	{
		generator.words(args.words);
	}
	else
	{
		generator.words(6);
	}

	generator.capitalizeWords = args.capitalize.to!(Flag!"capitalizeWords");
	generator.useDigits = args.digits;
	generator.useSymbols = args.symbols;
	generator.leetProbability = args.leetProbability;
	generator.separator = args.separator;

	std.range.generate(() => generator.generate)
		.take(args.number)
		.each!writeln;

	return 0;
}
