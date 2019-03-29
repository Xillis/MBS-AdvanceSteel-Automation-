(DXF_BUILD_BLOCK "H:\\DRAWING\\ALLSTEEL\\75522\\Andwg-3.dxf" "RFRM-1")

(defun DXF_BUILD_BLOCK (FILENAME BLOCKNAME / BLOCKDATA ELEMENT OLDVAR)
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq OLDVAR (CWL-SVVCF (list '("CMDECHO" 0))))
	;;Generat Doted pair list for DXF file
	(setq BLOCKDATA (DXF_BUILD_LIST FILENAME BLOCKNAME))
	(Print BLOCKDATA)
	;;brake the Block data in to Elements
	(foreach x BLOCKDATA
		(if (= (car x) 0)
			(progn
				(print (reverse ELEMENT))
				(setq ELEMENT (null ELEMENT))
			)
		)
		(if (not (null ELEMENT))
			(setq ELEMENT (cons x ELEMENT))
			(setq ELEMENT (list x))
		)
	)
	(print (reverse ELEMENT))
	(CWL-SVVCF OLDVAR)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
)


;;Generats a list for a block definition fron a DXF file
(defun DXF_BUILD_LIST (FILENAME BLOCKNAME / DXFFILE RL DXFDATA BLOCKDATA MARKER)
	;;Load DXF file in to program 
	(setq DXFFILE (open FILENAME "r"))
	;;Search DXF data for block and extract Block Data
	(setq RL (read-line DXFFILE))
	(while (not (null RL))
		(if (= RL "BLOCKS")
			(while (not (= RL "ENDSEC"))
				(if (= RL BLOCKNAME)
					(while (not (= RL "ENDBLK"))
						(setq RL (read RL))
						(setq DXFDATA (append (list RL) DXFDATA))
						(setq RL (read-line DXFFILE))
					)
				)
				(setq RL (read-line DXFFILE))
				(setq RL (vl-string-left-trim "." RL))
			)
		)	
		(setq RL (read-line DXFFILE))
	)
	;;convert raw Data to a Doted pair list
	(setq
		BLOCKDATA (list (cons (caddr DXFDATA) (cadr DXFDATA)))
		MARKER -1
		COUNT 0
		DXFDATA (member (caddr DXFDATA) DXFDATA)
	)
	(foreach x DXFDATA
		(setq COUNT (1+ COUNT))
		(if (not (minusp MARKER))
			(if (null (nth COUNT DXFDATA))
				(setq BLOCKDATA (cons (cons '2 x) BLOCKDATA))
				(setq BLOCKDATA (cons (cons (nth COUNT DXFDATA) x) BLOCKDATA))
			)
		)
		(setq MARKER (* -1 MARKER))
	)
	BLOCKDATA
)

;;Tools
(defun CWL-SVVCF ( sysvar / sysvar oldvar)
	;;(print "start CWL-SVVCF")
	(foreach var sysvar
		(setq oldvar (append oldvar (list (list(nth 0 var) (getvar (nth 0 var))))))
		(setvar (nth 0 var) (nth 1 var))
	)
	;;(print "end CWL-SVVCF")
	oldvar
)