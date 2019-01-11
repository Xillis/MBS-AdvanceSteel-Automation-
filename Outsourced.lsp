(defun c:SBS-OUTSOURCED ( / SSPLATE INDEX OBJ WIDTH THICKNESS MODELROLE SSHOLE HOLE HOLEIDEX)
	(print "SBS-OUTSOURCED V0.1.0")
	(vl-load-com)
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq 
		SSPLATE(ssget "_A" '((0 . "ASTPLATE")))
		INDEX 0
	)
	(while (/= NIL(setq OBJ (ssname SSPLATE INDEX)))
		(setq NAME (getpropertyvalue OBJ "Name"))
		(setq 
			MODELROLE (getpropertyvalue OBJ "Model Role")
			WIDTH (distof (vl-string-subst "'-" "' " (substr NAME (+ 2(vl-string-position (ascii "x") NAME)))) 4)
			THICKNESS (distof (getpropertyvalue OBJ "Thickness") 2)
		)
		(cond 
			(
				(and 
					(or (= MODELROLE "Web plateR") (= MODELROLE "Web plateC"))
					(or (< 0.5 THICKNESS) (<  72 WIDTH))
				)
				(VLAX-PUT-PROPERTY (VLAX-ENAME->VLA-OBJECT OBJ) 'Layer "AS_Special Order Plate")
			)
			(
				(and
					(not (or (= MODELROLE "Web plateR") (= MODELROLE "Web plateC")))
					(or (< 1 THICKNESS) (<  12 WIDTH))
				)
				(VLAX-PUT-PROPERTY (VLAX-ENAME->VLA-OBJECT OBJ) 'Layer "AS_Special Order Plate")
			)
			(
				(<= .75 THICKNESS)
				(progn
					(setq
						SSHOLE(ssget "_A" '((0 . "ASTHOLEPLATE")))
						HOLEIDEX 0
					)
					(while (/= NIL(setq HOLE (ssname SSHOLE HOLEIDEX)))
					(print (getpropertyvalue OBJ "Hole type"))
					(print (distof (getpropertyvalue OBJ "Hole diameter") 2))
					)
				)
			)
			(T nIL)
		)
		(setq INDEX (1+ INDEX))
	)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(prin1)
) 

