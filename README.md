# Don Worth's Beneath Apple DOS

Don Worth wrote a very cool book for the Apple II.  Actually, he wrote several,
but here is one of them that I happened to need.  He found a bunch of his disks
containing the original text in his garage, and he was happy to have [his
original disks][dons-disks] be released into the hands of whomever might want to
use them.  Since the OCR versions of this book are ... less than great ... I've
decided to try and convert his originals.


## The Goal

I'd like to see a proper version of this book.  Text, figures, all of it.  To do
that is not going to be trivial, but it starts with clean text.  We don't have
that on [archive.org][], yet, but perhaps we can fix that?  Please feel free to
join in--send patches, help add stuff, etc.


## The method

1. The DOS 3.3 disks were dumped using cppo
2. Apply the following transformations to each document file:
   * For characters 0xa0-0xfe, strip the high bit to get pure ASCII
   * Convert 0x0d and 0x8d (return) characters ti 0x0a (newline)
   * Escape all else in C-style
3. Remove NUL at end of .txt files
4. .pp dot command is paragraph break, replace with blank line.
5. Remove trailing whitespace
6. Normalize case and spacing of dot commands (lowercase here)


This has probably broken the .s files a bit, and I haven't bothered to decompile
the five byte HELLO ...  ;)

[dons-disks]: http://www.6502lane.net/2015/03/12/don-worths-beneath-apple-dos-original-text-files/
[archive.org]: https://archive.org/
