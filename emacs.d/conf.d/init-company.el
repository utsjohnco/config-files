(use-package company-tern :ensure t :pin melpa)

(use-package company :ensure t :pin melpa
  :config
  (setq-default company-lighter-base "Ⓒ")
  (setq-default company-show-numbers          1)
  (setq-default company-idle-delay            0.05) ; start completion immediately
  (setq-default company-minimum-prefix-length 1)    ; start completion after 1 character.
  (setq-default company-tooltip-align-annotations t)
  (global-company-mode 1))
