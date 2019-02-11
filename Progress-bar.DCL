PROGRESS_BAR : dialog {
	fixed_width = true;
	label = "Progress";
	key = "PB_LABLE";
	: column {
		: image {
			key = "PGBAR";
			width = 50;
			height = 2;
		}
		: button {
			label = "Close";
			mnemonic = "C";
			key = "Close";
			is_cancel = true;
		}
	}
}