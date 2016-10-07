Nonterminals segments segment_spec.
Terminals '[' ']' '<' '>' '{' '}' '...' segment.
Rootsymbol segments.

segments -> segment_spec          : [ '$1' ].
segments -> segment_spec segments : ['$1'|'$2'].

segment_spec -> segment           : extract_token('$1').
segment_spec -> '[' segments ']'  : [optional | '$2'].
segment_spec -> '{' segments '}'  : [repeatable | '$2'].
segment_spec -> '<' segments '>'  : [withChildren | '$2'].

Erlang code.

extract_token({_Token, _Line, Value}) -> unicode:characters_to_binary(Value, unicode, utf8).
