Scriptname slw_interface_alp Hidden

Import Debug
import slw_util

Int Function getPeeLevelALP(GlobalVariable apb, GlobalVariable apbm ) Global
	float val = apbm.GetValue()
	if val == 0
		return percentToState5(0)
	endif
	int p = (apb.GetValue()/val * 100) as Int
	return percentToState5(p)
EndFunction