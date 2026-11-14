#nim c -d:release hexdump.nim

import std/[os, strformat, strutils]

const BytesPerLine = 16

proc printable(b: byte): char =
  if b >= 0x20'u8 and b <= 0x7E'u8:
    result = char(b)
  else:
    result = '.'

proc hexDump(path: string) =
  var f: File
  if not open(f, path, fmRead):
    stderr.writeLine("Error: cannot open '" & path & "'")
    quit(1)

  var buf: array[BytesPerLine, byte]
  var offset = 0

  while true:
    let n = f.readBytes(buf, 0, BytesPerLine)
    if n == 0:
      break

    var hexPart = ""
    var asciiPart = ""
    for i in 0 ..< BytesPerLine:
      if i == BytesPerLine div 2:
        hexPart.add(" ")
      if i < n:
        hexPart.add(toLowerAscii(toHex(int(buf[i]), 2)))
        hexPart.add(" ")
        asciiPart.add(printable(buf[i]))
      else:
        hexPart.add("   ")

    echo &"{offset:08x}  {hexPart} |{asciiPart}|"
    offset += n

  echo &"{offset:08x}"
  close(f)

if paramCount() != 1:
  stderr.writeLine("Usage: hexdump <file>")
  quit(1)

hexDump(paramStr(1))
