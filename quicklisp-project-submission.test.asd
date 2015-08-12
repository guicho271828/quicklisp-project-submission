#|
  This file is a part of quicklisp-project-submission project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#


(in-package :cl-user)
(defpackage quicklisp-project-submission.test-asd
  (:use :cl :asdf))
(in-package :quicklisp-project-submission.test-asd)


(defsystem quicklisp-project-submission.test
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :description "Test system of quicklisp-project-submission"
  :license "LLGPL"
  :depends-on (:quicklisp-project-submission
               :fiveam)
  :components ((:module "t"
                :components
                ((:file "package"))))
  :perform (load-op :after (op c) (eval (read-from-string "(every #'fiveam::TEST-PASSED-P (5am:run! :quicklisp-project-submission))"))
))
