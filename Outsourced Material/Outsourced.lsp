(defun c:SBS-OUTSOURCED ( / OLDVAR SSPLATE INDEX OBJ WIDTH THICKNESS MODELROLE SSHOLE TOTAL-FOUND HOLEINDEX BBLOW BBHIGH HOLE HSIZE NAME SKIP)
	(prompt  "SBS-OUTSOURCED V1.3.0")
	(vl-load-com)
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq OLDVAR (CWL-SVVCF (list '("CMDECHO" 0)'("CLAYER" "0")'("LUNITS" 2))))
	(command-s "-LAYER" "M" "AS_Special Order Plate" "C" 4 "AS_Special Order Plate" "L" "Continuous" "AS_Special Order Plate" "")
	(setq 
		SSPLATE(ssget "_A" '((0 . "ASTPLATE")))
		INDEX 0
		TOTAL-FOUND 0 
		SKIP 0
	)
	(acet-ui-progress "Looking For Outsourced Plates:" (sslength ssplate))
	(command-s "-VIEW" "SAVE" "vtemp")
	(command-s "ASTORSWITCHREPRMODE" "DEFAULT" SSPLATE "")
	(command-s "UCS" "W")
	(command-s "PLAN" "" "")
	(while (/= NIL(setq OBJ (ssname SSPLATE INDEX)))
		(setq NAME (getpropertyvalue OBJ "Name"))
		(setq 
			MODELROLE (getpropertyvalue OBJ "Model Role")
			WIDTH (distof (vl-string-subst "'-" "' " (substr NAME (+ 2(vl-string-position (ascii "x") NAME)))) 4)
		)
		(IF  (null (setq THICKNESS (distof (getpropertyvalue OBJ "Thickness") 2)))
			(setq THICKNESS (distof (getpropertyvalue OBJ "Thickness") 4))
		)
		(if (= (getvar "INSUNITS") 4)
			(setq THICKNESS (* THICKNESS 0.03937))
		)
		(cond
			(
				(= 0 WIDTH)
				(setq SKIP (1+ SKIP))
				(prompt (strcat "\nError found in plate: " NAME))
			)
			(
				(> 0.14 THICKNESS)
				(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
				(setq TOTAL-FOUND (1+ TOTAL-FOUND))
				(command-s "_AstM4CommMarkSelAdd" OBJ "")
			)
			(
				(and 
					(or (= MODELROLE "Web plateR") (= MODELROLE "Web plateC"))
					(or (< 0.5 THICKNESS) (<  71 WIDTH))
				)
				(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
				(setq TOTAL-FOUND (1+ TOTAL-FOUND))
				(command-s "_AstM4CommMarkSelAdd" OBJ "")
			)
			(
				(and
					(not (or (= MODELROLE "Web plateR") (= MODELROLE "Web plateC")))
					(or (< 1 THICKNESS) (<  12 WIDTH))
				)
				(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
				(setq TOTAL-FOUND (1+ TOTAL-FOUND))
				(command-s "_AstM4CommMarkSelAdd" OBJ "")				
			)
			(
				(progn
					(command-s "_astm4changerep" OBJ "")
					(vla-getboundingbox (vlax-ename->vla-object OBJ) 'BBLOW 'BBHIGH)
					(setq
						BBLOW (vlax-safearray->list BBLOW)
						BBHIGH (vlax-safearray->list BBHIGH)
						SSHOLE(ssget "_C" BBLOW BBHIGH '((0 . "ASTHOLEPLATE")))
						HOLEINDEX 0
					)
					(command-s "ASTORSWITCHREPRMODE" "DEFAULT" OBJ "")					
					(if (not (null SSHOLE))
						(while (/= NIL(setq HOLE (ssname SSHOLE HOLEINDEX)))
							(IF (null (distof (getpropertyvalue OBJ "Thickness") 2))
								(setq HSIZE (distof (getpropertyvalue HOLE "Hole diameter") 4))
								(setq HSIZE (distof (getpropertyvalue HOLE "Hole diameter") 2))
							)
							(if (= (getvar "INSUNITS") 4)
								(setq HSIZE (* HSIZE 0.03937))
							)								
							(cond
								(
									(and
										(>= THICKNESS 1)
										(or (<= HSIZE 0.9375) (>= HSIZE 1.375))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
									(setq TOTAL-FOUND (1+ TOTAL-FOUND))
									(command-s "_AstM4CommMarkSelAdd" OBJ "")
								)
								(
									(and
										(>= THICKNESS 0.875)
										(or (<= HSIZE 0.8125 ) (>= HSIZE 1.5625))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
									(setq TOTAL-FOUND (1+ TOTAL-FOUND))
									(command-s "_AstM4CommMarkSelAdd" OBJ "")
								)
								(
									(and
										(>= THICKNESS 0.75)
										(or (<= HSIZE 0.6875) (>= HSIZE 1.75))
									)
									(vlax-put-property (vlax-ename->vla-object OBJ) 'Layer "AS_Special Order Plate")
									(setq TOTAL-FOUND (1+ TOTAL-FOUND))
									(command-s "_AstM4CommMarkSelAdd" OBJ "")
								)
								(T NIL)
							)
							(setq HOLEINDEX (1+ HOLEINDEX))
						)
					)
				)
			)
			(T NIL)
		)
		(setq INDEX (1+ INDEX))
		(acet-ui-progress INDEX)
	)
	(acet-ui-progress)
	(command-s "-VIEW" "RESTORE" "vtemp")
	(command-s "-VIEW" "DELETE" "vtemp")
	(if (not (= SKIP 0))
		(prompt (strcat "\n" (itoa SKIP) " Plates skipped because of errors"))
	)
	(if (not (= TOTAL-FOUND 0))
		(progn
			(command-s "_AstM4CommSelectMarkedObjects")
			(command-s "AstM10ViewSelObjects_")
			(command-s "_AstM4CommUnmarkObjects")
			(prompt (strcat "\n" (itoa TOTAL-FOUND) " Outsourced plates found and set to layer AS_Special Order Plate"))
		)
		(prompt "No outsourced plates found")
	)
	(sssetfirst)
	(CWL-SVVCF OLDVAR)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(prin1)
) 

;;TOOLS

(defun *error* (msg)
  (princ "error: ")
  (princ msg)
 (princ)
)

(defun CWL-SVVCF ( SYSVAR / SYSVAR OLDVAR)
	;;(print "Start CWL-SVVCF")
	(foreach var SYSVAR
		(setq OLDVAR (append OLDVAR (list (list(nth 0 var) (getvar (nth 0 var))))))
		(setvar (nth 0 var) (nth 1 var))
	)
	;;(print "End CWL-SVVCF")
	OLDVAR
)