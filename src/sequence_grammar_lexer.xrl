Definitions.

NAME = [A-Z][A-Z0-9][A-Z0-9]
WHITESPACE = [\s\t\n\r]

Rules.

{NAME}        : {token, {segment, TokenLine, TokenChars}}.
\[            : {token, {'[', TokenLine}}.
\]            : {token, {']', TokenLine}}.
\<            : {token, {'<', TokenLine}}.
\>            : {token, {'>', TokenLine}}.
\{            : {token, {'{', TokenLine}}.
\}            : {token, {'}', TokenLine}}.
{WHITESPACE}+ : skip_token.

Erlang code.
