Scriptname slw_mcm extends SKI_ConfigBase

slw_widget property widget auto
slw_player property player Auto

slw_interface_slax Property slax Auto
slw_interface_apropos_two  property apropos2 auto

Int property updateInterval = 5 auto hidden
Bool property arousal = True auto hidden
Bool property exposure = True auto hidden
Bool property damage = True auto hidden


int _updateIntervalSlider
int _arousalToggle
int _exposureToggle
int _damageToggle

int SLWidget_Version = 1

; -- Version 2 --
int SLWidget_Version_2 = 2

slw_interface_fhu property fhu auto

Bool property cum = True auto hidden

int _cumToggle

; -- Version 3 --
int SLWidget_Version_3 = 3

slw_interface_mme property mme auto
slw_interface_pregnancy property pregnancy auto

Bool property milk = True auto hidden
Bool property lactacid = True auto hidden
Bool property isPregnant = True auto hidden

int _milkToggle
int _lactacidToggle
int _pregnancyToggle

; -- Version 4 --
int _slpToggle
slw_module_slp property slp auto
Bool property isSLP = True auto hidden

; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading
int function GetVersion()
	return 4
endFunction

event OnConfigInit()
	ModName = "SL Widgets"
	Debug.Notification("SL Widgets MCM menu initialized.")
endEvent

Event OnConfigClose()
	widget.UIUpdate()
endEvent

Event OnPageReset(string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("SL Widgets")
	syncInterfaces()
	_updateIntervalSlider = AddSliderOption("Update interval", 5, "{0}")
	AddEmptyOption()
	_arousalToggle = addToggleOption("Arousal Icon Enabled", arousal)
	_exposureToggle = addToggleOption("Exposure Icon Enabled", exposure)
	_damageToggle = addToggleOption("W&T Icon Enabled", damage)
	_cumToggle = addToggleOption("FHU Icon Enabled", cum)
	_milkToggle = addToggleOption("MME Milk Icon Enabled", milk)
	_lactacidToggle = addToggleOption("MME Lactacid Icon Enabled", lactacid)
	_pregnancyToggle = addToggleOption("Pregnancy Icon Enabled", isPregnant)
	_slpToggle = addToggleOption("Parasites Icon Enabled", isSLP)
endEvent

function syncInterfaces()
	if !slax.isInterfaceActive() 
		arousal = false
		exposure = false
	endIf
	
	if !apropos2.isInterfaceActive()
		damage = false
	endIf

	if !fhu.isInterfaceActive()
		cum = false
	endIf

	if !mme.isInterfaceActive()
		milk = false
		lactacid = false
	endIf

	if !pregnancy.isInterfaceActive()
		isPregnant = false
	endIf

	if !slp.isInterfaceActive()
		isSLP = false
	endIf
endFunction

Event onOptionHighlight(int mcm_option)
	If (mcm_option == _updateIntervalSlider)
		SetInfoText("Set the update interval of the widget.")
	ElseIf (mcm_option == _arousalToggle)
		SetInfoText("Toggle arousal icon")
	ElseIf (mcm_option == _exposureToggle)
		SetInfoText("Toggle exposure icon")
	ElseIf (mcm_option == _damageToggle)
		SetInfoText("Toggle wear and tear icons")
	ElseIf (mcm_option == _cumToggle)
		SetInfoText("Toggle fill her up icon")
	ElseIf (mcm_option == _milkToggle)
		SetInfoText("Toggle milk icons")
	ElseIf (mcm_option == _lactacidToggle)
		SetInfoText("Toggle lactacid icons")
	ElseIf (mcm_option == _pregnancyToggle)
		SetInfoText("Toggle pregnancy icons")
	ElseIf (mcm_option == _slpToggle)
		SetInfoText("Toggle parasites icons")
	endIf
endEvent

Event onOptionSelect(int mcm_option)
	if(mcm_option == _arousalToggle)
		arousal = !arousal 
		setToggleOptionValue(mcm_option, arousal) 
	elseIf(mcm_option == _exposureToggle)
		exposure = !exposure
		setToggleOptionValue(mcm_option, exposure)
	elseIf(mcm_option == _damageToggle)
		damage = !damage
		setToggleOptionValue(mcm_option, damage)
	elseIf(mcm_option == _cumToggle)
		cum = !cum
		setToggleOptionValue(mcm_option, cum)
	elseIf(mcm_option == _milkToggle)
		milk = !milk
		setToggleOptionValue(mcm_option, milk)
	elseIf(mcm_option == _lactacidToggle)
		lactacid = !lactacid
		setToggleOptionValue(mcm_option, lactacid)
	elseIf(mcm_option == _pregnancyToggle)
		isPregnant = !isPregnant
		setToggleOptionValue(mcm_option, isPregnant)
	elseIf(mcm_option == _slpToggle)
		isSLP = !isSLP
		setToggleOptionValue(mcm_option, isSLP)
	endIf
endEvent

Event OnOptionSliderOpen(Int mcm_option)
	If (mcm_option == _updateIntervalSlider)
		SetSliderDialogStartValue(updateInterval)
		SetSliderDialogRange(0, 60)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(5)
	endIf
EndEvent

Event OnOptionSliderAccept(Int mcm_option, Float Value)
	If (mcm_option == _updateIntervalSlider)
		updateInterval=Value as Int
		SetSliderOptionValue(mcm_option, Value, "{0}")
	EndIf
EndEvent