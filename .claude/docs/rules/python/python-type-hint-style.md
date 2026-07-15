---
trigger: glob
globs: *.py
---

Generate type hints for every functions and methods but avoiding using type hints for variable assignment. Use Python native type hints (PEP 604 syntax) with the pipe operator (`|` ) for union types instead of importing from typing module:

Examples:
  - Use `str | int`  instead of `Union[str, int]`
  - Use `str | None`  instead of `Optional[str]`
  - Use `list[str]`  instead of `List[str]`
  - Use `dict[str, int]`  instead of `Dict[str, int]`
  - Use `tuple[str, ...]`  instead of `Tuple[str, ...]`
