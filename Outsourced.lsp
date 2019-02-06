(defun c:SBS-OUTSOURCED ( / OLDVAR SSPLATE INDEX OBJ WIDTH THICKNESS MODELROLE SSHOLE HOLEINDEX BBLOW BBHIGH HOLE HSIZE NAME)
	(prompt "SBS-OUTSOURCED V1.0.2")
	(print)
	(vl-load-com)
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq OLDVAR (CWL-SVVCF (list '("CMDECHO" 0)'("CLAYER" "0"))))
	(COMMAND "-LAYER" "M" "AS_Special Order Plate" "C" 4 "AS_Special Order Plate" "L" "Continuous" "AS_Special Order Plate" "")
	(setq 
		SSPLATE(ssget "_A" '((0 . "ASTPLATE")))
		INDEX 0
	)
	(command-s "AstM4SwitchReprMode_" SSPLATE "")
	(command-s "UCS" "W")
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
				(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
			)
			(
				(and
					(not (or (= MODELROLE "Web plateR") (= MODELROLE "Web plateC")))
					(or (< 1 THICKNESS) (<  12 WIDTH))
				)
				(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
			)
			(
				(<= 0.75 THICKNESS)
				(progn
					(command-s "_astm4changerep" OBJ "")
					(vla-getboundingbox (vlax-ename->vla-object OBJ) 'BBLOW 'BBHIGH)
					(setq
						BBLOW (vlax-safearray->list BBLOW)
						BBHIGH (vlax-safearray->list BBHIGH)
						SSHOLE(ssget "_W" BBLOW BBHIGH '((0 . "ASTHOLEPLATE")))
						HOLEINDEX 0
					)				
					(if (not (null SSHOLE))
						(while (/= NIL(setq HOLE (ssname SSHOLE HOLEINDEX)))
							(setq HSIZE (atof(getpropertyvalue HOLE "Hole diameter")))
							(cond
								(
									(and
										(>= THICKNESS 1)
										(or (<= HSIZE 0.9375) (>= HSIZE 1.375))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
								)
								(
									(and
										(>= THICKNESS 0.875)
										(or (<= HSIZE 0.8125 ) (>= HSIZE 1.5625))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
								)
								(
									(and
										(>= THICKNESS 0.75)
										(or (<= HSIZE 0.6875) (>= HSIZE 1.75))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
								)
								(T NIL)
							)
							(setq HOLEINDEX (1+ HOLEINDEX))
						)
					)
					(command-s "AstM4SwitchReprMode_" OBJ "")
				)
			)
			(T NIL)
		)
		(setq INDEX (1+ INDEX))
	)
	(command-s "UCS" "P")
	(CWL-SVVCF OLDVAR)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(prompt "Out sourced material set to layer AS_Special Order Plate")
	(prin1)
) 

;;TOOLS

(defun CWL-SVVCF ( SYSVAR / SYSVAR OLDVAR)
	;;(print "Start CWL-SVVCF")
	(foreach var SYSVAR
		(setq OLDVAR (append OLDVAR (list (list(nth 0 var) (getvar (nth 0 var))))))
		(setvar (nth 0 var) (nth 1 var))
	)
	;;(print "End CWL-SVVCF")
	OLDVAR
)