# Diceware passphrases generator

Generates passphrases consisting of normal words.

Read about the concept of diceware at <https://theworld.com/~reinhold/diceware.html>.

## Examples

```
$ ./diceware --words 7
recognize spry blanching dislocate opulently game throwing

$ ./diceware --entropy 80 --wordlist eff_short_1 --capetalize 
Issue Repay Koala Bulge Stuff Ivory Smirk Card

$ ./diceware --digits 3 --symbols 2
cupb3arer princess unpaid $egm3nt regali@ bouncin6
```

## Usage

```
$ ./diceware --help
Usage: diceware [--number N] [--wordlist {eff_large,eff_short_1,eff_short_2,german}] [--read-wordlist FILENAME] [--entropy BITS] [--min-length LENGTH] [--max-length LENGTH] [--words WORDS] [--capitalize] [--digits N] [--symbols N] [--leet-probability PROBABILITY] [--separator CHARACTER] [-h]

Wordlist selection:
  --wordlist {eff_large,eff_short_1,eff_short_2,german}, -w {eff_large,eff_short_1,eff_short_2,german}
                       Use a built-in wordlist
  --read-wordlist FILENAME, -r FILENAME
                       Read in and use a wordlist

Passphrase length requirements:
  Generate a passphrase that has...

  --entropy BITS, -e BITS
                       at least this number of bits of entropy
  --min-length LENGTH, -l LENGTH
                       at least this many characters
  --max-length LENGTH, -L LENGTH
                       at most this many characters
  --words WORDS, -n WORDS
                       exactly this many words. --words=6 is the default.

Passphrase modifications:
  Change the passphrase in some way

  --capitalize, -C     Capitalize the individual words
  --digits N, -d N     Try to include this many digits
  --symbols N, -s N    Try to include this many symbols
  --leet-probability PROBABILITY, --leet PROBABILITY
                       Replace characters with 1337 versions with this
                       probability.Has no effect if --digits or --symbols is
                       given
  --separator CHARACTER, --sep CHARACTER
                       Use this to separate words (default is ' ')

Optional arguments:
  --number N, -c N     Number of passphrases to generate
  -h, --help           Show this help message and exit
```
