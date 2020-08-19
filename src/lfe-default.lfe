(defun start (x y u)
  (user_default:start x y u))

(defun start-run (tick)
  (user_default:start_run tick))

(defun stop-run ()
  (user_default:stop_run))

(defun set-units (unit uis)
  (user_default:set_units unit uis))

(defun set-units (unit from to)
  (set-units unit (lists:seq from to)))

(defun set-units (unit from to incr)
  (set-units unit (lists:seq from to incr)))
