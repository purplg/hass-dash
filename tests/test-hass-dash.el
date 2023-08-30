;;; test-hass-dash.el --- Tests of hass-dash -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:
(require 'ert)

(require 'hass-dash)

(setq hass-dash-test-layout
      `((default . ((hass-dash-group :title "Test Group One"
                                     (hass-dash-toggle :entity-id "test_entity.one")
                                     (hass-dash-toggle :entity-id "test_entity.two"))
                    (hass-dash-group :title "Test Group Two"
                                     (hass-dash-toggle :entity-id "test_entity.three"))))))

(ert-deftest hass-dash-track-layout-entities nil
  (with-current-buffer (get-buffer-create (hass-dash--buffer-name 'test))
    (hass-dash-mode)
    (let ((hass-dash-layout (cdr (assoc 'default hass-dash-test-layout)))
          (hass-tracked-entities '("explicit.entity")))
      (advice-add #'hass--update-tracked-entities :around (lambda (&rest _)))
      (let ((widget (widget-create (append '(group :format "%v") hass-dash-layout))))
        (should (member "explicit.entity" hass-tracked-entities))
        (should (member "test_entity.one" hass-tracked-entities))
        (should (member "test_entity.two" hass-tracked-entities))
        (should (member "test_entity.three" hass-tracked-entities))
        (widget-delete widget)))))

(ert-deftest hass-dash-create-widget-confirm-string nil
  (with-current-buffer (get-buffer-create (hass-dash--buffer-name 'test))
    (hass-dash-mode)
    (let ((confirm-called nil)
          (test-widget (widget-create 'hass-dash-toggle
                                      :entity-id hass-test-entity-id
                                      :confirm "Test confirmation?")))
      ;; Disable `y-or-n-p' from prompting and set `confirm-called' to t if the prompt is correct.
      (advice-add #'y-or-n-p
                  :around
                  (lambda (_ confirm)
                    (setq confirm-called (string= confirm "Test confirmation?"))
                    nil))
      (widget-apply-action test-widget)
      (should confirm-called))))

(ert-deftest hass-dash-create-widget-confirm-function nil
  (with-current-buffer (get-buffer-create (hass-dash--buffer-name 'test))
    (hass-dash-mode)
    (let* ((confirm-called nil)
           (test-widget (widget-create 'hass-dash-toggle
                                       :entity-id hass-test-entity-id
                                       :confirm (lambda (&rest _)
                                                  (setq confirm-called t)
                                                  nil))))
      (widget-apply-action test-widget)
      (should confirm-called))))

(ert-deftest hass-dash-create-widget-confirm-default nil
  (with-current-buffer (get-buffer-create (hass-dash--buffer-name 'test))
    (hass-dash-mode)
    (let ((confirm-called nil)
          (test-widget (widget-create 'hass-dash-toggle
                                      :entity-id hass-test-entity-id
                                      :confirm t)))
      ;; Disable `y-or-n-p' from prompting and set `confirm-called' to t if the prompt is correct.
      (advice-add #'y-or-n-p
                  :around
                  (lambda (_ confirm)
                    (setq confirm-called (string= confirm (concat "Toggle " hass-test-entity-id "? ")))
                    nil))
      (widget-apply-action test-widget)
      (should confirm-called))))

(ert-deftest hass-dash-create-widget-confirm-none nil
  (with-current-buffer (get-buffer-create (hass-dash--buffer-name 'test))
    (hass-dash-mode)
    (let ((confirm-called nil)
          (test-widget (widget-create 'hass-dash-toggle :entity-id hass-test-entity-id)))
      ;; Disable `y-or-n-p' from prompting and set `confirm-called' to t if the prompt is correct.
      (advice-add #'y-or-n-p
                  :around
                  (lambda (_ confirm)
                    (setq confirm-called t)
                    nil))
      (widget-apply-action test-widget)
      (should-not confirm-called))))
