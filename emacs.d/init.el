;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; emacs configuration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; these features require external tools
(defvar use-jshint-mode nil) ;; 'npm install jshint-mode' and set to t
(defvar use-rsense      nil) ;; install from git://github.com/m2ym/rsense.git

(nconc load-path (list "~/.emacs.d/el-get/el-get"))

(if (eq use-jshint-mode t)
  (add-to-list 'load-path "/usr/local/lib/node_modules/jshint-mode"))

(if (eq use-rsense t)
  (progn
    (setq rsense-home (expand-file-name "~/Projects/rsense"))
    (add-to-list 'load-path (concat rsense-home "/etc"))))

(require 'package)

(unless (require 'el-get nil t)
  (with-current-buffer
    (url-retrieve-synchronously
      "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (end-of-buffer)
    (eval-print-last-sexp)))

(nconc package-archives
  (list
    '("tromey" . "http://tromey.com/elpa/")
    '("marmalade" . "http://marmalade-repo.org/packages/")))

(package-initialize)

(setq el-get-sources
  '((:name ruby-mode
      :type elpa
      :load "ruby-mode.el")
     (:name inf-ruby
       :type elpa)
     (:name css-mode
       :type elpa)
     (:name rvm
       :type git
       :url "http://github.com/senny/rvm.el.git"
       :load "rvm.el"
       :compile ("rvm.el")
       :after (lambda() (rvm-use-default)))
     (:name yaml-mode
       :type git
       :url "http://github.com/yoshiki/yaml-mode.git"
       :features yaml-mode)
     (:name rhtml
       :type git
       :url "http://github.com/eschulte/rhtml.git"
       :features rhtml-mode)
     (:name zenburn
       :type http
       :url "http://github.com/djcb/elisp/raw/master/themes/zenburn-theme.el"
       :compile ("zenburn-theme.el")
     )))

(defvar required-packages
  '(ruby-mode inf-ruby css-mode rvm yaml-mode rhtml haml-mode auto-complete-css
     auto-complete-emacs-lisp auto-complete json lua-mode buffer-move
     markdown-mode coffee-mode flymake-ruby flymake-point nxhtml zenburn rinari
     ruby-electric))

(el-get 'sync required-packages)

(require 'auto-complete)
(require 'auto-complete-config)
(require 'uniquify)
(require 'flymake-point)
(require 'rinari)
(require 'ruby-electric)
(if (eq use-jshint-mode t)
    (require 'flymake-jshint))
(if (eq use-rsense t)
    (require 'rsense))

(ac-config-default)

(setq auto-mode-alist
  (append
    (list
      '("Gemfile$"    . ruby-mode)
      '("Rakefile$"   . ruby-mode)
      '("\\.gemspec$" . ruby-mode)
      '("\\.ru$"      . ruby-mode)
      '("\\.erb$"     . rhtml-mode)
      '("\\.yaml$"    . yaml-mode)
      '("\\.yml$"     . yaml-mode)
      '("\\.coffee$"  . coffee-mode)
      '("Cakefile$"   . coffee-mode)
      '("\\.scss$"    . css-mode)
      )
    auto-mode-alist))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; utility functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun backward-delete-char-hungry (arg &optional killp)
  "*Delete characters backward in \"hungry\" mode.
    See the documentation of `backward-delete-char-untabify' and
    `backward-delete-char-untabify-method' for details."
  (interactive "*p\nP")
  (let ((backward-delete-char-untabify-method 'hungry))
    (backward-delete-char-untabify arg killp)))

(defun hexcolour-luminance (colour)
  "Calculate the luminance of a color string"
  (let* ((values (color-values colour))
          (r (car values))
          (g (cadr values))
          (b (caddr values)))
    (floor (+ (* .3 r) (* .59 g) (* .11 b)) 256)))

(defun hexcolour-add-to-font-lock ()
  "Colorize HTML RGB colors (e.g. '#000030', 'DarkBlue') in font-lock-mode."
  (interactive)
  (font-lock-add-keywords nil
    `((,(concat "#[0-9a-fA-F]\\{6\\}\\|"
          (regexp-opt (defined-colors) 'words))
        (0 (let ((colour (match-string-no-properties 0)))
             (put-text-property
               (match-beginning 0) (match-end 0)
               'face `((:foreground, (if (> 128.0 (hexcolour-luminance colour))
                                       "white" "black"))
                        (:background ,colour)))))))))

(defun move-text-internal (arg)
  (cond
   ((and mark-active transient-mark-mode)
    (if (> (point) (mark))
        (exchange-point-and-mark))
    (let ((column (current-column))
          (text (delete-and-extract-region (point) (mark))))
      (forward-line arg)
      (move-to-column column t)
      (set-mark (point))
      (insert text)
      (exchange-point-and-mark)
      (setq deactivate-mark nil)))
   (t
    (let ((column (current-column)))
      (beginning-of-line)
      (when (or (> arg 0) (not (bobp)))
        (forward-line)
        (when (or (< arg 0) (not (eobp)))
          (transpose-lines arg))
        (forward-line -1))
      (move-to-column column t)))))

(defun move-text-down (arg)
  "Move region (transient-mark-mode active) or current line arg lines down."
  (interactive "*p")
  (move-text-internal arg))

(defun move-text-up (arg)
  "Move region (transient-mark-mode active) or current line arg lines up."
  (interactive "*p")
  (move-text-internal (- arg)))

(defun align-repeat (start end regexp)
  "Repeat alignment with respect to the given regular expression."
  (interactive "r\nsAlign regexp: ")
  (align-regexp start end
                (concat "\\(\\s-*\\)" regexp) 1 1 t))

(defun toggle-fullscreen ()
  "Switch between fullscreen and windowed mode"
  (interactive)
  (if (eq system-type 'darwin)
      (ns-toggle-fullscreen)
    (set-frame-parameter nil 'fullscreen (if (frame-parameter nil 'fullscreen)
                                             nil
                                           'fullboth))))

(defun scale-colour (colour factor)
  "Scale the given hex colour (#112233) by the given factor."
  (if window-system
      (let* ((values (color-values colour))
	     (r (floor (* factor (car values))))
	     (g (floor (* factor (cadr values))))
	     (b (floor (* factor (caddr values)))))
	(format "#%02x%02x%02x"
		(* (/ r 65280.0) 256)
		(* (/ g 65280.0) 256)
		(* (/ b 65280.0) 256)))
    colour))

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

(defun c-return ()
  "indent automatically on return"
  (interactive)
  (c-indent-line-or-region)
  (newline-and-indent))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; key bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "M-g")      'goto-line)
(global-set-key (kbd "C-c C-c")  'comment-region)
(global-set-key (kbd "C-c C-u")  'uncomment-region)
(global-set-key (kbd "C-c C-r")  'align-repeat)

(global-set-key [C-prior] 'previous-buffer)
(global-set-key [C-next]  'next-buffer)

(global-set-key [M-up]    'move-text-up)
(global-set-key [M-down]  'move-text-down)

(global-set-key (kbd "M-RET") 'toggle-fullscreen)

(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

(if (eq system-type 'darwin)
    (global-set-key (kbd "C-<kp-delete>") 'kill-word))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; appearance options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default ansi-term-color-vector [unspecified "black" "red4" "lime green"
                                                  "yellow3" "DeepSkyBlue"
                                                  "magenta4" "cyan3" "white"])
(if (eq system-type 'darwin)
    (setq default-frame-alist '((font . "Droid Sans Mono-14")))
  (setq default-frame-alist '((font . "Droid Sans Mono-12"))))

(setq frame-title-format   ;; frame title: user@host: buffer [modified?]
  (list
    (user-login-name)
    "@"
    (system-name)
    ": %b %+" ))

(setq line-number-mode t)              ; show line number in the mode line
(setq column-number-mode t)            ; show column number in the mode line
(which-function-mode t)                ; show current function in the mode line
(show-paren-mode t)                    ; highlight matching parentheses
(tool-bar-mode -1)                     ; no tool bar
(menu-bar-mode -1)                     ; no menu bar
(scroll-bar-mode -1)                   ; no scroll bar
(tooltip-mode -1)                      ; show tooltips in the echo area
(setq-default mumamo-chunk-coloring 2) ; don't highlight regions with terrible
                                       ; hideous colors
(load-theme 'wombat)
(set-face-background                   ; make trailing whitespace a little
 'trailing-whitespace                  ; darker than the default background
 (scale-colour
  (face-background 'default) 0.83))

; color tweaks for auto-complete box
(set-face-attribute 'ac-candidate-face nil
  :background (face-foreground 'default)
  :foreground (face-background 'default)
  :box nil)
(set-face-attribute 'ac-selection-face nil
  :background (face-foreground 'font-lock-keyword-face)
  :foreground "#000000"
  :bold t
  :box nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; behavior tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ac-auto-start 2)                    ; start autocomplete immediately
(setq-default ring-bell-function 'ignore) ; quiet down now
(fset 'yes-or-no-p 'y-or-n-p)             ; ask y/n instead of yes/no
(setq inhibit-startup-message t)          ; I've used emacs before, thanks
(setq-default kill-whole-line t)          ; `C-k` also removes trailing \n
(setq-default require-final-newline nil)  ; don't require files to end with \n
(setq-default next-line-add-newlines nil) ; don't add newlines when scrolling
                                          ; past end of buffer
(setq-default show-trailing-whitespace t) ; highlight trailing whitespace
(setq-default tab-width 4)                ; default tab width is 4 spaces
(setq-default indent-tabs-mode nil)       ; use spaces instead of tabs to indent
(setq-default lisp-indent-offset 2)       ; 2 spaces for indent
(delete-selection-mode t)                 ; inserting text with a selection
                                          ; deletes the selection
(setq-default fill-column 80)             ; wrap text at 80 characters
(setq-default scroll-conservatively 1)    ; scroll one line at a time when the
                                          ; focus moves past end of buffer
(iswitchb-mode t)                         ; use better `C-x b` buffer switching
(put 'downcase-region 'disabled nil)      ; these are useful commands
(put 'upcase-region   'disabled nil)      ; why are they disabled

(setq uniquify-buffer-name-style 'forward); better uniquify buffer naming
(setq uniquify-after-kill-buffer-p t)     ; remove uniquify name after killing
                                          ; a competing buffer
(setq truncate-partial-width-windows nil) ; don't truncate lines in spit windows
(defvar backup-directory-location         ; save backup files in a non-annoying
  "~/.cache/emacs")                       ; directory location
(setq backup-directory-alist `((".*" . ,backup-directory-location)))
(setq auto-save-file-name-transforms `((".*" ,backup-directory-location t)))

(if (eq system-type 'darwin) ; don't open files in seperate frames on OS X
    (setq ns-popup-frames 'nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; mode hooks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'text-mode-hook 'on-text-mode)
(add-hook 'c-mode-hook 'on-c-like-mode)
(add-hook 'lisp-mode-hook 'on-lisp-mode)
(add-hook 'js-mode-hook 'on-js-mode)
(add-hook 'emacs-lisp-mode-hook 'hexcolour-add-to-font-lock)
(add-hook 'css-mode-hook 'on-css-mode)
(add-hook 'nxml-mode-hook 'hexcolour-add-to-font-lock)
(add-hook 'ruby-mode 'on-ruby-mode)

(if (eq use-rsense t)
  (add-hook 'ruby-mode-hook
    (lambda ()
      (add-to-list 'ac-sources 'ac-source-rsense-method)
      (add-to-list 'ac-sources 'ac-source-rsense-constant))))

(defun on-ruby-mode ()
  (local-set-key (kbd "DEL") 'backward-delete-char-hungry))

(defun on-text-mode ()
  (flyspell-mode t))

(defun on-css-mode ()
  (hexcolour-add-to-font-lock)
  (setq css-indent-level 2))

(defun on-c-like-mode ()
  (c-set-style "k&r")
  (c-set-offset 'substatement-open 0)
  (c-toggle-auto-hungry-state 1)
  (flyspell-prog-mode)
  (flymake-mode t)
  (local-set-key (kbd "RET") 'c-return)
  (setq tab-width 4)
  (setq c-basic-offset 4))

(defun on-lisp-mode ()
  (flyspell-prog-mode)
  (setq lisp-indent-offset 2)
  (hexcolour-add-to-font-lock))

(defun on-js-mode ()
  (hexcolour-add-to-font-lock)
  (setq js-indent-level 2)
  (if (eq use-jshint-mode t)
      (flymake-mode t))
)
