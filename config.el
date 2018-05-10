;;; config.el --- inserting APL chars into a buffer
; -*- encoding: utf-8; indent-tabs-mode: nil -*-

;;     Emacs configuration script to help write APL and Perl 6 scripts
;;     Copyright (C) 2015, 2016, 2018 Jean Forget
;;
;;     This program is distributed under the GNU Public License version 1 or later
;;
;;     You can find the text of the license in the F<LICENSE> file or at
;;     L<http://www.gnu.org/licenses/gpl-1.0.html>.
;;
;;     Here is the summary of GPL:
;;
;;     This program is free software; you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation; either version 1, or (at your option)
;;     any later version.
;;
;;     This program is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with this program; if not, write to the Free Software Foundation,
;;     Inc., L<http://www.fsf.org/>.
;;
(progn
(defun apl-insert ()
       "Inserting an APL char"
       (interactive)
                     ; arithmetic     vector          program
                     ; mathematic
  (let* ((apl-conv '(("times"  . "×") ("rho"    . "⍴") ("gets"    . "←")
                     ("div"    . "÷") ("iota"   . "⍳") ("goto"    . "→")
                     ("neg"    . "¯") ("drop"   . "↓") ("del"     . "∇")
                     ("circ"   . "○") ("take"   . "↑") ("lamp"    . "⍝")
                     ("floor"  . "⌊") ("slbar"  . "⌿") ("quad"    . "⎕")
                     ("ceil"   . "⌈") ("slbck"  . "⍀") ("qquad"   . "⍞")
                     ("log"    . "⍟") ("elem"   . "∈") ("enquote" . "⍕")
                     ("domino" . "⌹") ("jot"    . "∘") ("dequote" . "⍎")
                     ("encode" . "⊤")
                     ("decode" . "⊥") ("rotate" . "⌽")
                     ("neq"    . "≠") ("transp" . "⍉")
                     ("leq"    . "≤")
                     ("geq"    . "≥") ("each"   . "¨")
                     ("or"     . "∨") ("enclose". "⊂")
                     ("and"    . "∧") ("disclose" . "⊃")
                     ("delta"  . "∆")
                     ))
          (ch1 (cdr (assoc (completing-read "Car ? "
                                            (mapcar 'car apl-conv)
                                            nil t)
                            apl-conv))))
     (insert ch1))
)
(global-set-key '[f6] 'apl-insert)

(global-set-key '[f5] 'other-window)
(global-font-lock-mode -1)
(mouse-avoidance-mode "proteus")
)
