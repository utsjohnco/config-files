(require 'use-package)

(use-package rainbow-delimiters :ensure t :pin melpa)

(use-package cider :ensure t :pin melpa)

(use-package clojure-mode :ensure t :pin melpa
  :config
  (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode))