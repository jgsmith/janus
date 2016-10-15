# Mensendi

![master build status](https://travis-ci.org/jgsmith/mensendi.svg?branch=master)

Mensendi is a project with which I'm learning Elixir. It's also a combination HL7 integration
engine and protected health information vault. For now, it's focused on capturing the HL7v2.5
message structures and the ability to parse messages into useful data structures.

## Character Set Conversions

Mensendi uses [codepagex]() to manage character conversions. For now, it supports a sub-set of the
character sets specified in the HL7 documentation:

- ASCII (embedded as \\C2842\\)
- UNICODE UTF-8
- 8859/1 (embedded as \\C2D41\\)
- 8859/2
- 8859/3
- 8859/4
- 8859/5
- 8859/6
- 8859/7
- 8859/8
- 8859/9


The Unicode conversion files are not checked in to the repository. You will need to run the following command to download the files:

```shell
mix codepagex.unicode
```

This assumes that `wget` is available and in your path.
