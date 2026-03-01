; Datastar attribute highlighting for templ is applied via extmarks in
; lua/datastar/init.lua (apply_templ_datastar_hl). Tree-sitter query files
; were not used because vim.treesitter.query.set strips the `; inherits: go`
; directive, breaking Go syntax highlighting in templ buffers.
