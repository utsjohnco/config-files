;;; ruby.el - ruby mode customization for emacs
;; John Ledbetter <john.ledbetter@gmail.com>

;; fix ruby-mode multi-line parameter indentation
(setq-default ruby-deep-indent-paren       nil)
(setq-default ruby-deep-indent-paren-style nil)
(setq-default ruby-deep-arglist            nil)

(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
         indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

;; add additional filenames to ruby-mode
(nconc auto-mode-alist
  (list
    '("Gemfile$"    . ruby-mode)
    '("Rakefile$"   . ruby-mode)
    '("\\.gemspec$" . ruby-mode)
    '("\\.ru"       . ruby-mode)
    '("\\.rake"     . ruby-mode)))


(defun align-ruby-hash (BEG END)
  (interactive "r")
  (align-regexp BEG END ":\\(\\s-*\\)" 1 1))

(add-hook 'ruby-mode-hook
  '(lambda ()
     (local-set-key (kbd "C-c a") 'align-ruby-hash)
     (local-set-key (kbd "C-c b") 'magit-blame-mode)
     (local-set-key (kbd "C-c s") 'rspec-toggle-spec-and-target)
     (rainbow-mode t)
     (ruby-electric-mode t)
     (electric-pair-mode t)))

