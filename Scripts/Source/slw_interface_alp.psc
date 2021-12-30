Scriptname slw_interface_alp Hidden

Import Debug
import slw_util

Int Function getPeeLevelALP(GlobalVariable apb, GlobalVariable apbm ) Global
	int p = (apb.GetValue()/apbm.GetValue() * 100) as Int
	
	return percentToState5(p)
EndFunction