import macros
import shared

template get_id(variable: untyped): untyped =
  cast[typeof variable](addr variable)

macro show(elems: varargs[untyped]): untyped =
  for el in elems:
    echo el.toStrLit
