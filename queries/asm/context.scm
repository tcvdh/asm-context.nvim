;; filepath: asm-context.nvim/queries/asm/context.scm
;; Assembly context queries

;; Match labels (most common context)
(label) @context

;; Match comments that might denote sections
((comment) @context
 (#match? @context "^;+\\s*SECTION"))

;; Match directives that denote sections or functions
((directive) @context
 (#match? @context "^\\.(text|data|bss|section|global|globl)"))

;; Match function declarations
((directive
  (directive_name) @directive_name
  (directive_operand) @directive_operand)
 (#eq? @directive_name ".type")
 (#match? @directive_operand "@function"))
@context