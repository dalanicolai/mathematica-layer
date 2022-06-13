;;; packages.el --- mathematica layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2022 Sylvain Benner & Contributors
;;
;; Author: Daniel Nicolai <dalanicolai@2a02-a45d-af56-1-666c-72af-583a-b92d.fixed6.kpn.net>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(defconst mathematica-packages
  '((wolfram-mode :location (recipe :fetcher github
                                    :repo "dalanicolai/wolfram-mode"))
    (ob-wolfram :location (recipe :fetcher github
                                    :repo "dalanicolai/wolfram-mode"))))

;; .m files are not associated because conflict with more common Objective-C and
;; MATLAB/Octave, manually invoke for .m files.
(defun mathematica/init-wolfram-mode ()
  (use-package wolfram-mode
    :interpreter "wolframscript -f"
    :mode "\\.m\\'" "\\.wls\\'"
    :init
    (with-eval-after-load 'org-babel
      (add-to-list 'org-babel-load-languages '(wolfram . t) t))

    (with-eval-after-load 'ob-jupyter
      (add-to-list 'org-src-lang-modes '("jupyter-Wolfram-Language" . "wolfram")))

    (with-eval-after-load 'lsp-mode
      (add-to-list 'lsp-language-id-configuration '(wolfram-mode . "Mathematica"))

      (lsp-register-client
       (make-lsp-client :new-connection (lsp-tcp-server-command
                                         (lambda (port)
                                           `("wolframscript"
                                             "-file"
                                             ,(expand-file-name mathematica-wl-server-path)
                                             ,(concat
                                               "--socket="
                                               (number-to-string port)
                                               ))))
                        :activation-fn (lsp-activate-on "Mathematica")
                        :server-id 'lsp-wl)))

    (add-hook 'wolfram-mode-hook 'lsp)
    :config
    (spacemacs/set-leader-keys-for-major-mode 'org-mode
      "mm" 'mathematica-ob-process-export-html-block)))

(defun mathematica/init-ob-wolfram ()
  (use-package ob-wolfram
    :after wolfram-mode))

