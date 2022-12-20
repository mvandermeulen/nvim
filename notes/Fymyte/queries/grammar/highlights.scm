[
  (name)
  (rule_name)
] @variable

"::=" @operator
"or" @keyword.operator
":" @punctuation.delimiter
[
  "("
  ")"
] @punctuation.bracket

(regex) @string.special

(modifier) @operator

(string) @string
(comment) @comment
(ERROR) @error
