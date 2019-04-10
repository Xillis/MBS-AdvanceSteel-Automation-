;;pulls a block definition from a DXF detemins scale from a block in the DXF and inserts it in to the current drawing

(defun C:SBS_DXF_BLOCK_INSERT (/ TEMPDWG FILEPATH SCALE OLDVAR)
	(print "C:SBS_DXF_BLOCK_INSERT V0.1.0")
	(vla-StartUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
	(setq OLDVAR (CWL-SVVCF (list '("CMDECHO" 0) '("CLAYER" "0") '("OSMODE" 0))))
	;;get the file location from user
	(setq FILEPATH(GETFILED "GET FILE" (getvar "dwgprefix") "DXF" 8 ))
	;;open a new drawing in autocad
	(setq TEMPDWG (vla-add (vla-get-documents (vlax-get-acad-object)) "SBS_Template.dwt"))
	;;inser the file in to the open drawing
	(vla-Import TEMPDWG FILEPATH (vlax-3d-point 0 0 0) 1)
	(vl-cmdf "-purge" "b" (strcat "RF" (substr FILEPATH (+ 7 (vl-string-search "RfDwg" FILEPATH)) 1) "TBL") "n")
	(if (not 
			(vl-catch-all-error-p
				(vl-catch-all-apply 'vla-item 
					(list 
						(vla-get-blocks
							(vla-get-ActiveDocument
								(vlax-get-acad-object)
							)
						)
						(strcat "RF" (substr FILEPATH (+ 7 (vl-string-search "RfDwg" FILEPATH)) 1) "TBL")
					)
				)
			)
		)
		(CWL_SEC_BLOCK_NAME (strcat "RF" (substr FILEPATH (+ 7 (vl-string-search "RfDwg" FILEPATH)) 1) "TBL"))
	)
	;;copy block in to current drawing
	(cond
		((vl-string-search "RfDwg" FILEPATH)
			(vla-CopyObjects
				TEMPDWG
				(vlax-safearray-fill
					(vlax-make-safearray vlax-vbObject '(0 . 0))
					(list (vla-item (vla-get-blocks TEMPDWG)(strcat "RF" (substr FILEPATH (+ 7 (vl-string-search "RfDwg" FILEPATH)) 1) "TBL")))
				)
				(vla-get-blocks
					(vla-get-activedocument (vlax-get-acad-object))
				)
			)
		)
		(t (print "Chosen file was not a RfDwg DXF file"))
	)
	;;close open file
	(vla-close TEMPDWG :vlax-false)
	;;release file from memory
	(vlax-release-object TEMPDWG)
	;;get scale of DXF file
	(setq SCALE (* (/ 1 (DXF_GET_SCALE FILEPATH "LOGO")) 0.75 ))
	;;insert block to specified scale
	(vla-insertblock
		(vla-get-paperspace
			(vla-get-activedocument (vlax-get-acad-object))
		)
		(vlax-3d-point 8.1172 21.7500 0)
		(strcat "RF" (substr FILEPATH (+ 7 (vl-string-search "RfDwg" FILEPATH)) 1) "TBL") SCALE SCALE SCALE 0
	)
	(CWL-SVVCF OLDVAR)
	(vla-EndUndoMark 
		(vla-get-ActiveDocument 
			(vlax-get-acad-object)
		)
	)
)

;;gets the scale of a specified block definition {BLOCKNAME} fron a DXF {FILENAME} file.
(defun DXF_GET_SCALE (FILENAME BLOCKNAME / DXFFILE RL SCALE)
	;;Load DXF file in to program 
	(setq DXFFILE (open FILENAME "r"))
	;;Search DXF data for block and extract scale
	(setq RL (read-line DXFFILE))
	(while (not (null RL))
		(if (= RL "ENTITIES")
			(while (not (= RL "ENDSEC"))
				(if (= RL BLOCKNAME)
					(while (not (= RL "INSERT"))
						(if (= (vl-string-trim " " RL) "41")
							(progn
								(setq SCALE (atof (vl-string-trim " "(read-line DXFFILE))))
							)
						)
						(setq RL (read-line DXFFILE))
					)
				)
				(setq RL (read-line DXFFILE))
				(setq RL (vl-string-left-trim "." RL))
			)
		)	
		(setq RL (read-line DXFFILE))
	)
	SCALE
)

;;tools

;;sets specified sys vars to values specified and returns the old values in a list
(defun CWL-SVVCF ( SYSVAR / SYSVAR OLDVAR)
	;;(print "Start CWL-SVVCF")
	(foreach var SYSVAR
		(setq OLDVAR (append OLDVAR (list (list(nth 0 var) (getvar (nth 0 var))))))
		(setvar (nth 0 var) (nth 1 var))
	)
	;;(print "End CWL-SVVCF")
	OLDVAR
)
;;renames a block with the old name + a sequentioal letter eq. "block name"-A
(defun CWL_SEC_BLOCK_NAME (OLD-BLOCK-NAME / NEW-BLOCK-NAME SUFFIX )
(setq
	SUFFIX "A"
	NEW-BLOCK-NAME (strcat OLD-BLOCK-NAME "-" SUFFIX)
)
(while (not 
			(vl-catch-all-error-p
				(vl-catch-all-apply 'vla-item 
					(list 
						(vla-get-blocks
							(vla-get-ActiveDocument
								(vlax-get-acad-object)
							)
						)
						NEW-BLOCK-NAME
					)
				)
			)
		)
		
		(setq
			SUFFIX (chr (1+ (ascii SUFFIX)))
			NEW-BLOCK-NAME (strcat OLD-BLOCK-NAME "-" SUFFIX)
		)
	)
	(vla-put-Name
		(vla-item
			(vla-get-Blocks
				(vla-get-ActiveDocument
					(vlax-get-acad-object)
				)
			)
		OLD-BLOCK-NAME)
	NEW-BLOCK-NAME)
)