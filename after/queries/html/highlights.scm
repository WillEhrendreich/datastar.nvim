; Datastar attribute highlighting for HTML
; Highlights data-* attribute names with semantic coloring

; Match data-* attribute names
((attribute_name) @tag.attribute
  (#match? @tag.attribute "^data-"))
