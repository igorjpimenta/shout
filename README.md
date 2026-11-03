# shout

`shout` is a tiny command-line tool that reads text from stdin or from
file arguments and prints every input line UPPERCASED. It is a single
Python 3 script with no dependencies beyond the standard library.

## Requirements

- Python 3.8 or newer.

## Install

Clone the repository and make the script executable:

```sh
git clone https://github.com/igorjpimenta/shout
cd shout
chmod +x shout
```

There is nothing else to install. Run it directly as `./shout`, or add
the directory to your `PATH` to call it as `shout`.

## Usage

```
shout [--trim] [file ...]
```

With no file arguments, `shout` reads stdin. With one or more file
arguments, it reads each file in order and writes the uppercased lines
to stdout. If a final line has no trailing newline, the output keeps it
that way.

### Uppercase stdin

```sh
$ echo hello | ./shout
HELLO
```

```sh
$ printf 'hello\nworld\n' | ./shout
HELLO
WORLD
```

### Uppercase files

```sh
$ printf 'foo\nbar\n' > file.txt
$ ./shout file.txt
FOO
BAR
```

Multiple file arguments are read in order:

```sh
$ printf 'foo\n' > a.txt
$ printf 'bar\n' > b.txt
$ ./shout a.txt b.txt
FOO
BAR
```

### Trim lines before uppercasing (`--trim`)

`--trim` strips surrounding whitespace from each line before
uppercasing it. Whitespace inside the line is untouched. The flag may
appear anywhere among the arguments:

```sh
$ echo ' hi ' | ./shout --trim
HI
```

```sh
$ printf '  a b  \n' | ./shout --trim
A B
```

### Unknown flags

Any argument starting with `-` other than `--trim` is rejected. The
error goes to stderr, nothing is written to stdout, and the process
exits with status 2:

```sh
$ ./shout --bogus
shout: unknown flag: --bogus
$ echo $?
2
```

This applies to any unrecognized flag, not just `--bogus`:

```sh
$ ./shout -x
shout: unknown flag: -x
$ echo $?
2
```

## Exit codes

| Code | Meaning |
| ---- | ------- |
| `0`  | Success. All input was read and written. |
| `1`  | I/O error. A file argument does not exist or cannot be opened (for example, it is a directory). The error message names the offending path. |
| `2`  | Unknown flag. The error message names the flag. |

Examples of the `1` case:

```sh
$ ./shout nope.txt
shout: no such file: nope.txt
$ echo $?
1
```

```sh
$ ./shout .
shout: is a directory: .
$ echo $?
1
```
