SBS_CRANE_SELECTION : dialog {
	label = "Crane Selection";
	key = "dlg_CSelect";
	:row{
		:column {
			width = 20;
			fixed_width = true;
			:row{
				:button {
					label = "Imperial";
					key = "Imp";
				}
				:button {
					label = "Metric";
					key = "Metric";
				}
			}
		}
	}
	:row {
		:column {
			:list_box{
				label = "Select Crane From List";
				key = "Crane";
				width = 20;
				fixed_width = true;
				height = 10;
				fixed_height = true;
				multiple_select = false;
			}
		}
		spacer_1;
		:column {
			:edit_box {
				label = "Crane System:";
				key = "Crane System";
				width = 3;
				fixed_width = true;
			}
			:boxed_row {
				:column {
					width = 25;
					fixed_width = true;
					:text {
						label = "Crane Span: ";
						key = "CraneSpanT";
					}
					:text {
						label = "Crane Type: ";
						key = "CraneTypeT";
					}
					:text {
						label = "Vertical Frame Impact: ";
						key = "VerticalFrameImpactT";
					}
					:text {
						label = "Number of Cranes: ";
						key = "NumberofCranesT";
					}
					:text {
						label = "Crane Seperation: ";
						key = "CraneSeperation";
					}
					:text {
						label = "Vertical Beam Deflection: ";
						key = "VerticalBeamDeflectionT";
					}
					:text {
						label = "Horizontal Beam Deflection: ";
						key = "HorizontalBeamDeflectionT";
					}
					:text {
						label = "Vertical Beam Impact: ";
						key = "VerticalBeamImpactT";
					}
					spacer_1;
				}
				:column {
					:text {
						label = "Crane Span";
						key = "Crane Span";
						value = "n/a";
					}
					:text {
						label = "Crane Type";
						key = "Crane Type";
						value = "n/a";
					}
					:text {
						label = "Vertical Frame Impact";
						key = "Vertical Frame Impact";
						value = "n/a";
					}
					:text {
						label = "Number of Cranes";
						key = "Number of Cranes";
						value = "n/a";
					}
					:text {
						label = "Crane Seperation";
						key = "Crane Seperation";
						value = "n/a";
					}
					:text {
						label = "Vertical Beam Def";
						key = "Vertical Beam Deflection";
						value = "n/a";
					}
					:text {
						label = "Horizontal Beam Def";
						key = "Horizontal Beam Deflection";
						value = "L/400";
					}
					:text {
						label = "Vertical Beam Impact";
						key = "Vertical Beam Impact";
						value = "n/a";
					}
					spacer_1;
				}
			}
			:row {
				:popup_list {
					label = "Crane Number:";
					key = "CraneNumber";
					width = 17;
					fixed_width = true;
				}
			}
			:boxed_row{
				:column {
					width = 25;
					fixed_width = true;
					:text {
						label = "Control: ";
						key = "ControlT";
					}
					:text {
						label = "Crane Capacity: ";
						key = "CraneCapacityT";
						value = "n/a";
					}
					:text {
						label = "Crane Classification: ";
						key = "CraneClassificationT";
					}
					:text {
						label = "Bridge Weight: ";
						key = "BridgeWeightT";
						value = "n/a";
						}
					:text {
						label = "Trolley Weight: ";
						key = "TrolleyWeightT";
						value = "n/a";
					}
					:text {
						label = "Number of Wheels: ";
						key = "NumberofWheelsT";
					}
					:text {
						label = "Wheel Load: ";
						key = "WheelLoadT";
						value = "n/a";
					}
					:text {
						label = "Side Thrust: ";
						key = "SideThrustT";
					}
					:text {
						label = "Tractive Force: ";
						key = "TractiveForceT";
					}
				}
				:column {
					:text {
						label = "Control";
						key = "Control";
						value = "n/a";
					}
					:text {
						label = "Crane Capacity";
						key	= "Crane Capacity";
						value = "n/a";
					}
					:text {
						label = "Crane Classification";
						key = "Crane Classification";
						value = "n/a";
					}
					:text {
						label = "Bridge Weight";
						key = "Bridge Weight";
						value = "n/a";
					}
					:text {
						label = "Trolley Weight";
						key = "Trolley Weight";
						value = "n/a";
					}
					:text {
						label = "Number of Wheels";
						key = "Number of Wheels";
						value = "n/a";
					}
					:text {
						label = "Wheel Load";
						key = "Wheel Load";
						value = "n/a";
					}
					:text {
						label = "Side Thrust";
						key = "Side Thrust";
						value = "n/a";
					}
					:text {
						label = "Tractive Force";
						key = "Tractive Force";
						value = "n/a";
					}
				}
			spacer_1;
			}
			
		}
	}
	:column{
		children_alignment = centered;
		:row{
			width = 20;
			fixed_width = true;
			:button {
				label = "Insert";
				key = "accept";
				is_default = true;
				width = 10;
				fixed_width = true;
			}
			:button {
				label = "Cancle";
				key = "cancle";
				is_cancel = true;
				width = 10;
				fixed_width = true;
			}
		}
	}
	errtile;
}