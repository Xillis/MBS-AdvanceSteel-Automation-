SBS_CRANE_SELECTION : dialog {
	label = "Crane Selection";
	key = "dlg_CSelect";
	:boxed_row {
		:column {
			:list_box{
				label = "Select Crane From List";
				key = "Crane";
				Fixed_width = 25;
				Fixed_height = 8;
				multiple_select = false;
			}
		}
	}
	ok_cancel;
}