#|
  This file is a part of quicklisp-project-submission project.
  Copyright (c) 2015 Masataro Asai (guicho2.71828@gmail.com)
|#

#|
  Submit a local git repository to github, then make an issue @ github.com/quicklisp/quicklisp-projects/issues

  Author: Masataro Asai (guicho2.71828@gmail.com)
|#



(in-package :cl-user)
(defpackage quicklisp-project-submission-asd
  (:use :cl :asdf))
(in-package :quicklisp-project-submission-asd)


(defsystem quicklisp-project-submission
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:cl-github-v3 :cl-dot :trivia :alexandria)
  :components ((:module "src"
                :components
                ((:file "package"))))
  :description "Submit a local git repository to github, then make an issue @ github.com/quicklisp/quicklisp-projects/issues"
  :in-order-to ((test-op (load-op :quicklisp-project-submission.test))))
