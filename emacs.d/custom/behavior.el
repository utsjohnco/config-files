;;; behavior.el - customization for varios emacs behavior
;; John Ledbetter <john.ledbetter@gmail.com>

(setq kill-whole-line t)            ; include EOL when killing lines
(setq-default indent-tabs-mode nil) ; never use tabs for indenting
(setq-default tab-width 2)          ; 2 spaces per tab
(iswitchb-mode t)                   ; enhanced buffer switching
(delete-selection-mode t)           ; when region is active, delete kills region
(setq ring-bell-function 'ignore)   ; don't beep on error/end of buffer
(put 'downcase-region 'disabled nil)
(put 'upcase-region   'disabled nil)

(defalias 'yes-or-no-p 'y-or-n-p)   ; always ask Y/N? instead of yes/no.

; don't let the point go into the minibuffer prompt
(setq minibuffer-prompt-properties
  (plist-put minibuffer-prompt-properties 'point-entered
    'minibuffer-avoid-prompt))

; stop writing annoying autosave files to the current directory.
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(defun toggle-fullscreen ()
  "Switch between fullscreen and windowed mode"
  (interactive)
  (if (eq system-type 'darwin)
      (ns-toggle-fullscreen) ; OS-X
    (set-frame-parameter nil 'fullscreen
      (if (frame-parameter nil 'fullscreen) nil 'fullboth))))

; iswitchb customization
(defadvice iswitchb-kill-buffer (after rescan-after-kill activate)
  "*Regenerate the list of matching buffer names after a kill.
    Necessary if using `uniquifiy' with `uniquify-after-kill-buffer-p'
    set to non-nil."
  (setq iswitchb-buflist iswitchb-matches)
  (iswitchb-rescan))

(defun iswitchb-rescan ()
  "*Regenerate the list of matching buffer names."
  (interactive)
  (iswitchb-makealist iswitchb-default)
  (setq iswitchb-rescan t))

(setq iswitchb-buffer-ignore
  '("^ " "^\\*[^s][^c][^r][^a][^t][^c][^h]"))


; greedy whitespace delete
(defun backward-delete-char-hungry (arg &optional killp)
  "*Delete characters backward in \"hungry\" mode.
    See the documentation of `backward-delete-char-untabify' and
    `backward-delete-char-untabify-method' for details."
  (interactive "*p\nP")
  (let ((backward-delete-char-untabify-method 'hungry))
    (backward-delete-char-untabify arg killp)))


(defun reopen-file-with-sudo ()
  "Open the currently visited file as root via sudo."
  (interactive)
  (if (buffer-file-name)
    (let ((file-name (buffer-file-name)))
      (kill-buffer (current-buffer))
      (find-file (concat "/sudo:root@localhost:" file-name))
      (message "now editing %s as root" file-name))))

