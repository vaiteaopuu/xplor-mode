;;; xplor-mode.el ---- simple major mode for editing xplor script

;; Copyright © 2017, by vaitea OPUU

;; Author: vaitea OPUU (vaiteaopuu@gmail.com)
;; Version: 0.0.0
;; Created: 14 april 2017
;; Keywords: fasta, sequences, dna, protein, viewing

;; This file is not part of GNU Emacs.

;;; License:

;; You can redistribute this program and/or modify it under the terms of the GNU
;; General Public License version 3.

;;; Commentary:

;; Just syntax highlight for now.

;; full doc on how to use here

;;; Code:

;;; Key words
(setq xplor-cond-key-words
      '("if" "end if" "else"
        "then" "elseif" "write"
        "set" "close" "or" "and"))

(setq xplor-loop-key-words
      '("for" "in" "loop" "do" "show"
        "end" "while"))

(setq xplor-command-words
      '("surf" "struct" "coor" "evaluate"
        "flags" "cons" "stop" "chain" "link"
        "nbonds" "parameter[s]*" "not" "vector"
        "hbuild" "ener" "segment" "topology"
        "mini" "energy"))

(setq xplor-special-words
      '("display" "powel" "eval" "pick"))

(setq xplor-constants
      '("TRUE" "FALSE" "\d+" "true" "false"))

(setq xplor-variables
      '("\$[:alnum:]+"))

(defvar xplor-font-lock-defaults
  `((
     ( ,(regexp-opt xplor-cond-key-words 'symbols) . font-lock-builtin-face)
     ( ,(regexp-opt xplor-loop-key-words 'symbols) . font-lock-builtin-face)
     ( ,(regexp-opt xplor-command-words 'symbols) . font-lock-builtin-face)
     ( ,(regexp-opt xplor-special-words 'symbols) . font-lock-keyword-face)
     ( ,(regexp-opt xplor-constants 'symbols) . font-lock-constant-face)
     (font-lock-add-keywords nil '((xplor-variables . 'font-lock-variable-name-face)))
     ))
  )

;;; Indentation

(defun xplor-indent-line ()
  "Indent current line as WPDL code."
  (interactive)
  (beginning-of-line)
  (setq xplor-command-name-regexp  "\\(^[^!]* \\|^\\)\\(cons\\|while\\|surf\\|struct\\|flags\\|cons\\|chain\\|link\\|nbonds\\|parameter[s]*\\|hbuild\\|ener\\|segment\\|topology\\|mini\\|energy\\|then\\|else\\|elseif\\|loop\\)\\( .*\\|[ \t]*\n\\)")
  (if (bobp)
      (indent-line-to 0)       ; First line is always non-indented
    (let ((not-indented t) cur-indent)
      (if (looking-at "^[ \t]*\\(end\\|else\\|elseif\\)") ; If the line we are looking at is the end of a block, then decrease the indentation
          (progn
            (save-excursion
              (forward-line -1)
              (setq cur-indent (- (current-indentation) (* 2 default-tab-width))))
            (if (< cur-indent 0) ; We can't indent past the left margin
                (setq cur-indent 0)))
        (save-excursion
          (while not-indented ; Iterate backwards until we find an indentation hint
            (forward-line -1)
            (if (looking-at "^[ \t]*end.*$") ; This hint indicates that we need to indent at the level of the END_ token
                (progn
                  (setq cur-indent (current-indentation))
                  (setq not-indented nil))
              (if (not (looking-at "[^!]* end$"))
                  (if (looking-at xplor-command-name-regexp)
                      (progn
                        (setq cur-indent (+ (current-indentation) (* 2 default-tab-width))) ; Do the actual indenting
                        (setq not-indented nil))
                    (if (bobp)
                        (setq not-indented nil))))))))
      (if cur-indent
          (indent-line-to cur-indent)
        (indent-line-to 0))))) ; If we didn't see an indentation hint, then allow no indentation

;;; Xplor-mode
(define-derived-mode xplor-mode fundamental-mode "xplor"
  "fasta-mode is a major mode for editing xplor script."
  (setq font-lock-defaults xplor-font-lock-defaults)
  (font-lock-add-keywords nil '(("\d+" . 'font-lock-constant-face)))
  (font-lock-add-keywords nil '(("\\$[^ \(\)=\t\n\r]+" . 'font-lock-variable-name-face)))
  (font-lock-add-keywords nil '(("\\@" . 'font-lock-constant-face)))
  (font-lock-add-keywords nil '(("^[ \t]*\\(remark[s]?\\|REMARK[S]?\\).*" . 'font-lock-string-face)))
  (font-lock-add-keywords nil '(("\!.*" . 'font-lock-comment-face)))
  (font-lock-add-keywords nil '(("^\n[ \t]*\![\-\=]+\n\\([ \t]*\!.*\n\\)*[ \t]*\![\-\=]+" . 'font-lock-type-face)))

  (set (make-local-variable 'indent-line-function) 'xplor-indent-line)

  ;; Comment syntax
  (setq comment-start "!")

  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.inp\\'" . xplor-mode))

;; add the mode to the `features' list
(provide 'xplor-mode)

;; Local Variables&#58;
;; coding: utf-8
;; End:

;;; xplor-mode.el ends here
