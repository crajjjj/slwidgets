Scriptname iWant_Status_Bars_MCM extends SKI_ConfigBase

iWant_Status_Bars Property iBars Auto
Import FISSFactory

Int activeBar = 0
Int activePosition = 0
Int activeIcon = 0
Int activeState = 0
String[] stateNames

Bool pos_locked = True
Int min_pos_x = 0
Int min_pos_y = 0
Int max_pos_x = 1279
Int max_pos_y = 719

String SETTINGS_FILENAME = "iWant\\iWantStatusBars\\settings.xml"
String DELIMITER = "|"

Int Function GetVersion()
	Return 3
EndFunction

Event OnConfigInit()
	Pages = new String[3]
	Pages[0] = "Main"
	Pages[1] = "Bars"
	Pages[2] = "Icons"
EndEvent

Event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version
	If (a_version >= 2 && CurrentVersion < 2)
		Debug.Trace(self + ": Updating script to version 2")
		Pages = new string[2]
		Pages[0] = "Bars"
		Pages[1] = "Icons"
	EndIf
	If (a_version >= 3 && CurrentVersion < 3)
		Debug.Trace(self + ": Updating script to version 2.04")
		Pages = new String[3]
		Pages[0] = "Main"
		Pages[1] = "Bars"
		Pages[2] = "Icons"
		iBars._versionUpdate(3)
	EndIf
EndEvent

Event OnPageReset(string page)
	Int i
	Int icon
	String iconLabel

	If (page == "")
		LoadCustomContent("iWant/iWant Widgets.dds")
		Return
	Else
		UnloadCustomContent()
	EndIf

	stateNames = Utility.CreateStringArray(iBars.MAX_STATES_PER_ICON, "")
	i = 0
	While i < iBars.MAX_STATES_PER_ICON
		stateNames[i] = iBars._getIconStateName(activeIcon, i)
		i += 1
	EndWhile

	SetCursorPosition(0)
	SetCursorFillMode(TOP_TO_BOTTOM)
	
	If (page == "Bars")
		If iBars.isReady()
			AddHeaderOption("Bar Selection: READY")
		Else
			AddHeaderOption("Bar Selection: NOT READY")
			Return
		EndIf

		AddSliderOptionST("BAR", "Change to bar", activeBar)
		AddHeaderOption("Details for Bar " + (activeBar As String))
		AddMenuOptionST("BAR_TYPE", "Type", iBars.AVAILABLE_BAR_TYPES[iBars._getBarType(activeBar)])
		AddSliderOptionST("BAR_X", "X Position", iBars._getBarX(activeBar))
		AddSliderOptionST("BAR_Y", "Y Position", iBars._getBarY(activeBar))
		AddSliderOptionST("BAR_ICON_SIZE", "Icon Size", iBars._getBarIconSize(activeBar))
		AddToggleOptionST("BARSHOWONCHANGE", "Auto Hide", iBars._getBarShowOnChange(activeBar))
		AddSliderOptionST("BARAUTOHIDETIME", "Auto Hide Time", iBars._getBarAutoHideTime(activeBar))
		AddToggleOptionST("BARHIDEALPHA0", "Skip Hidden Icons", iBars._getBarHideOnAlpha0(activeBar))
		AddHeaderOption("Hotkeys")
		AddToggleOptionST("BARPRESSTOTOGGLE", "Press to Toggle", iBars._getBarPressToToggle(activeBar))
		AddToggleOptionST("BARHOLDTOSHOW", "Hold to Display", iBars._getBarHoldToShow(activeBar))
		AddKeyMapOptionST("HOTKEY", "Hotkey", iBars._getBarHotkey(activeBar))

		; Messy code to deal with not building in a "No icon" value that works in an array from the start
		activeIcon = iBars._getBarIcon(activeBar, activePosition)
		If activeIcon < 0
			If iBars._claimedBlankIcon >= 0
				activeIcon = iBars._claimedBlankIcon
			Else
				activeIcon = 0
			EndIf
		EndIf
		If activeState < 0
			activeState = 0
		EndIf

		; List positions
		SetCursorPosition(1)
		AddHeaderOption("Icon Selection for Bar " + (activeBar As String))
		AddSliderOptionST("POSITION", "Change to position", activePosition)
		i = 0
		While i < iBars.ICONS_PER_STATUS_BAR
			icon = iBars._getBarIcon(activeBar, i)
			If icon >= 0
				iconLabel = (i As String) + " - " + iBars.iconLabel[icon]
			Else
				If iBars._claimedBlankIcon >= 0
					iconLabel = (i As String) + " - " + iBars.iconLabel[iBars._claimedBlankIcon]
				Else
					iconLabel = (i As String) + " - " + "No Icon - No Icon"
				EndIf
			EndIf

			If i == activePosition
				AddMenuOptionST("BARICON", iconLabel, "")
			Else
				AddTextOptionST("BARICONMOD" + (i As String), iconLabel, "", OPTION_FLAG_DISABLED)
			EndIf
			i += 1
		EndWhile

	ElseIf (page == "Icons")
		If iBars.isReady()
			AddHeaderOption("Icon Selection: READY")
		Else
			AddHeaderOption("Icon Selection: NOT READY")
			Return
		EndIf
		
		If activeIcon < 0
			If iBars._claimedBlankIcon >= 0
				activeIcon = iBars._claimedBlankIcon
			Else
				activeIcon = 0
			EndIf
		EndIf
		If activeState < 0
			activeState = 0
		EndIf

		AddMenuOptionST("ICON", iBars.iconLabel[activeIcon], "")
		AddHeaderOption("State Selection")
		AddMenuOptionST("STATECHANGE", iBars._getIconStateName(activeIcon, activeState), "")

		SetCursorPosition(20)
		AddHeaderOption("Troubleshooting")
		AddToggleOptionST("DESTROYICON", "Destroy Icon", False)

		SetCursorPosition(1)
		AddHeaderOption("Configure State")
		AddTextOptionST("STATENULL", "State", iBars._getIconStateName(activeIcon, activeState), OPTION_FLAG_DISABLED)
		AddTextOptionST("SOURCEMODNULL", "Mod", iBars._getIconSourceModName(activeIcon), OPTION_FLAG_DISABLED)
		AddHeaderOption("Details")
		AddSliderOptionST("STATEALPHA", "Alpha", iBars._getIconAlpha(activeIcon, activeState))
		AddColorOptionST("STATECOLOR", "Color", iBars._getIconRGB(activeIcon, activeState))
		AddHeaderOption("Advanced Color Adjustment")
		AddSliderOptionST("STATERED", "Red", iBars._getIconRed(activeIcon, activeState))
		AddSliderOptionST("STATEGREEN", "Green", iBars._getIconGreen(activeIcon, activeState))
		AddSliderOptionST("STATEBLUE", "Blue", iBars._getIconBlue(activeIcon, activeState))

	ElseIf (page == "Main")
		If iBars.isReady()
			AddHeaderOption("Library: READY")
		Else
			AddHeaderOption("Library: NOT READY")
			Return
		EndIf
		AddTextOptionST("LOADSETTINGS", "Load", "Go")
		AddTextOptionST("SAVESETTINGS", "Save", "Go")
		AddToggleOptionST("POSITIONLOCK", "Position Sliders Locked", pos_locked)
	EndIf
EndEvent

State BAR
	Event OnSliderOpenST()
		SetSliderDialogStartValue(activeBar)
		SetSliderDialogDefaultValue(activeBar)
		SetSliderDialogRange(0, (iBars.TOTAL_STATUS_BARS - 1))
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		activeBar = value As Int
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
		activeBar = 0
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Select which bar to configure")
	EndEvent
EndState

State BAR_X
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getBarX(activeBar))
		SetSliderDialogDefaultValue(((max_pos_x + 1) / 2))
		SetSliderDialogRange(min_pos_x, max_pos_x)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setBarX(activeBar, value As Int)
		SetSliderOptionValueST(iBars._getBarX(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarX(activeBar, ((max_pos_x + 1) / 2))
		SetSliderOptionValueST(iBars._getBarX(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set the horizontal origin of the bar")
	EndEvent
EndState

State BAR_Y
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getBarY(activeBar))
		SetSliderDialogDefaultValue(((max_pos_y + 1) / 2))
		SetSliderDialogRange(min_pos_y, max_pos_y)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setBarY(activeBar, value As Int)
		SetSliderOptionValueST(iBars._getBarY(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarY(activeBar, ((max_pos_y + 1) / 2))
		SetSliderOptionValueST(iBars._getBarY(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set the vertical origin of the bar")
	EndEvent
EndState

State BAR_TYPE
	event OnMenuOpenST()
		SetMenuDialogStartIndex(iBars._getBarType(activeBar))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(iBars.AVAILABLE_BAR_TYPES)
	endEvent

	event OnMenuAcceptST(int index)
		iBars._setBarType(activeBar, index)
		iBars._resizeBar(activeBar)
		iBars._drawBar(activeBar)
		SetMenuOptionValueST(iBars.AVAILABLE_BAR_TYPES[index])
	endEvent

	event OnDefaultST()
		iBars._setBarType(activeBar, 0)
		iBars._resizeBar(activeBar)
		iBars._drawBar(activeBar)
		SetMenuOptionValueST(iBars.AVAILABLE_BAR_TYPES[0])
	endEvent

	event OnHighlightST()
		SetInfoText("Select bar style")
	endEvent
endState

State BAR_ICON_SIZE
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getBarIconSize(activeBar))
		SetSliderDialogDefaultValue(25)
		SetSliderDialogRange(0, 150)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setBarIconSize(activeBar, value As Int)
		iBars._resizeBar(activeBar)
		SetSliderOptionValueST(iBars._getBarIconSize(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarIconSize(activeBar, 25)
		iBars._resizeBar(activeBar)
		SetSliderOptionValueST(iBars._getBarIconSize(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set the size of individual icons in the bar")
	EndEvent
EndState

State POSITION
	Event OnSliderOpenST()
		SetSliderDialogStartValue(activePosition)
		SetSliderDialogDefaultValue(activePosition)
		SetSliderDialogRange(0, (iBars.ICONS_PER_STATUS_BAR - 1))
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		activePosition = value As Int
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
		activePosition = 0
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Select which position to configure")
	EndEvent
EndState

State BARICON
	event OnMenuOpenST()
		SetMenuDialogStartIndex(iBars._getBarIcon(activeBar, activePosition))
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(iBars.iconLabel)
	endEvent

	event OnMenuAcceptST(int index)
		Int oldicon = iBars._getBarIcon(activeBar, activePosition)
		If oldicon >= 0
			iBars._hideIcon(oldicon)
			iBars._moveIconOffscreen(oldicon)
		EndIf
		iBars._setBarIcon(activeBar, activePosition, index)
		iBars._resizeIconToBar(index, activeBar)
		iBars._resetIconVisibility(index)
		iBars._drawBar(activeBar)
		ForcePageReset()
	endEvent

	event OnDefaultST()
		Int oldicon = iBars._getBarIcon(activeBar, activePosition)
		If oldicon >= 0
			iBars._hideIcon(oldicon)
			iBars._moveIconOffscreen(oldicon)
		EndIf
		iBars._clearBarPosition(activeBar, activePosition)
		iBars._drawBar(activeBar)
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("Select status icon to place in current position")
	endEvent
endState

State STATECHANGE
	Event OnMenuOpenST()
		SetMenuDialogStartIndex(activeState)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(stateNames)
	EndEvent

	Event OnMenuAcceptST(int index)
		activeState = index
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
		activeState = 0
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Select which state to configure")
	EndEvent
EndState

State STATECOLOR
	event OnColorOpenST()
		SetColorDialogStartColor(iBars._getIconRGB(activeIcon, activeState))
		SetColorDialogDefaultColor(0xFFFFFF)
	endEvent

	event OnColorAcceptST(int color)
		iBars._setIconRGB(activeIcon, activeState, color)
		iBars._resetIconVisibility(activeIcon)
		iBars._drawBar(activeBar)
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState))
	endEvent

	event OnDefaultST()
		iBars._setIconRGB(activeIcon, activeState, 0xFFFFFF)
		iBars._resetIconVisibility(activeIcon)
		iBars._drawBar(activeBar)
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState))
	endEvent

	event OnHighlightST()
		SetInfoText("Set color of selected state of current icon")
	endEvent
endState

State STATEALPHA
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getIconAlpha(activeIcon, activeState))
		SetSliderDialogDefaultValue(100)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setIconAlpha(activeIcon, activeState, value As Int)
		iBars._resetIconVisibility(activeIcon)
		iBars._drawBar(activeBar)
		SetSliderOptionValueST(iBars._getIconAlpha(activeIcon, activeState))
	EndEvent

	Event OnDefaultST()
		iBars._setIconAlpha(activeIcon, activeState, 100)
		iBars._resetIconVisibility(activeIcon)
		iBars._drawBar(activeBar)
		SetSliderOptionValueST(iBars._getIconAlpha(activeIcon, activeState))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set alpha (transparency) of selected state of current icon")
	EndEvent
EndState

State DESTROYICON
	Event OnSelectST()
		iBars._clearBarPosition(activeBar, activePosition)
		iBars._releaseIconByID(activeIcon)
		activeIcon = iBars._claimedBlankIcon
		ForcePageReset()
	EndEvent

	Event OnDefaultST()
		iBars._clearBarPosition(activeBar, activePosition)
		iBars._releaseIconByID(activeIcon)
		activeIcon = iBars._claimedBlankIcon
		ForcePageReset()
	EndEvent

	Event OnHighlightST()
		SetInfoText("!!CAUTION!! Completely destroys the current icon.  Mods deploying icons should normally remove them without this function.  It is provided for scenarios where that does not occur.")
	EndEvent
EndState

State BARAUTOHIDETIME
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getBarAutoHideTime(activeBar))
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(5, 90)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setBarAutoHideTime(activeBar, value As Int)
		SetSliderOptionValueST(iBars._getBarAutoHideTime(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarAutoHideTime(activeBar, 30)
		SetSliderOptionValueST(iBars._getBarAutoHideTime(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Specify how long auto hiding icons stay visible")
	EndEvent
EndState

State BARSHOWONCHANGE
	Event OnSelectST()
		iBars._setBarShowOnChange(activeBar, !iBars._getBarShowOnChange(activeBar))
		If iBars._getBarShowOnChange(activeBar)
			iBars._hideBar(activeBar)
		EndIf
		SetToggleOptionValueST(iBars._getBarShowOnChange(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarShowOnChange(activeBar, False)
		SetToggleOptionValueST(iBars._getBarShowOnChange(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("Auto hide icons after the specified number of seconds, icon returns whenever a change occurs")
	EndEvent
EndState

State BARHIDEALPHA0
	Event OnSelectST()
		iBars._setBarHideOnAlpha0(activeBar, !iBars._getBarHideOnAlpha0(activeBar))
		SetToggleOptionValueST(iBars._getBarHideOnAlpha0(activeBar))
	EndEvent

	Event OnDefaultST()
		iBars._setBarHideOnAlpha0(activeBar, False)
		SetToggleOptionValueST(iBars._getBarHideOnAlpha0(activeBar))
	EndEvent

	Event OnHighlightST()
		SetInfoText("When set, icons that are hidden are not drawn and remaining icons are shifted into their place")
	EndEvent
EndState

State ICON
	event OnMenuOpenST()
		SetMenuDialogStartIndex(activeIcon)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(iBars.iconLabel)
	endEvent

	event OnMenuAcceptST(int index)
		Int oldIcon = activeIcon
		Int bar
		
		If oldIcon >= 0
			iBars._hideIcon(oldIcon)
			iBars._moveIconOffscreen(oldIcon)
		EndIf
		activeIcon = index
		iBars._resetIconVisibility(activeIcon)
		bar = iBars._findBarOfIcon(activeIcon)
		If bar >= 0
			iBars._resizeIconToBar(activeIcon, bar)
			iBars._drawBar(bar)
		EndIf
		activeState = 0
		ForcePageReset()
	endEvent

	event OnDefaultST()
		Int oldIcon = activeIcon
		Int bar
		
		If oldIcon >= 0
			iBars._hideIcon(oldIcon)
			iBars._moveIconOffscreen(oldIcon)
		EndIf
		activeIcon = 0
		iBars._resetIconVisibility(activeIcon)
		bar = iBars._findBarOfIcon(activeIcon)
		If bar >= 0
			iBars._resizeIconToBar(activeIcon, bar)
			iBars._drawBar(bar)
		EndIf
		ForcePageReset()
	endEvent

	event OnHighlightST()
		SetInfoText("Select icon to review or alter")
	endEvent
endState

State STATERED
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getIconRed(activeIcon, activeState))
		SetSliderDialogDefaultValue(255)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setIconRed(activeIcon, activeState, value As Int)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconRed(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnDefaultST()
		iBars._setIconRed(activeIcon, activeState, 255)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconRed(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set red channel of selected state of current icon")
	EndEvent
EndState

State STATEGREEN
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getIconGreen(activeIcon, activeState))
		SetSliderDialogDefaultValue(255)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setIconGreen(activeIcon, activeState, value As Int)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconGreen(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnDefaultST()
		iBars._setIconGreen(activeIcon, activeState, 255)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconGreen(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set green channel of selected state of current icon")
	EndEvent
EndState

State STATEBLUE
	Event OnSliderOpenST()
		SetSliderDialogStartValue(iBars._getIconBlue(activeIcon, activeState))
		SetSliderDialogDefaultValue(255)
		SetSliderDialogRange(0, 255)
		SetSliderDialogInterval(1)
	EndEvent

	Event OnSliderAcceptST(float value)
		iBars._setIconBlue(activeIcon, activeState, value As Int)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconBlue(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnDefaultST()
		iBars._setIconBlue(activeIcon, activeState, 255)
		iBars._resetIconVisibility(activeIcon)
		SetSliderOptionValueST(iBars._getIconBlue(activeIcon, activeState))
		SetColorOptionValueST(iBars._getIconRGB(activeIcon, activeState), False, "STATECOLOR")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Set blue channel of selected state of current icon")
	EndEvent
EndState

State LOADSETTINGS
	Event OnSelectST()
		_loadAllSettings()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Load bar information and icon state color/alpha configurations. Wait for 'Load Complete' message once activated.")
	EndEvent
EndState

State SAVESETTINGS
	Event OnSelectST()
		_saveAllSettings()
	EndEvent

	Event OnDefaultST()
	EndEvent

	Event OnHighlightST()
		SetInfoText("Save bar information and icon state color/alpha configurations. Wait for 'Save Complete' message once activated.")
	EndEvent
EndState

State HOTKEY
	Event OnKeyMapChangeST(int newKeyCode, string conflictControl, string conflictName)
		iBars._setBarHotkey(activeBar, newKeyCode)
		SetKeyMapOptionValueST(newKeyCode)
	EndEvent

	Event OnDefaultST()
		iBars._setBarHotkey(activeBar, -1)
		SetKeyMapOptionValueST(-1)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Specify the activation key for this bar if using hotkey functionality")
	EndEvent
EndState

State BARPRESSTOTOGGLE
	Event OnSelectST()
		iBars._setBarPressToToggle(activeBar, !iBars._getBarPressToToggle(activeBar))
		SetToggleOptionValueST(iBars._getBarPressToToggle(activeBar))
		SetToggleOptionValueST(iBars._getBarHoldToShow(activeBar), False, "BARHOLDTOSHOW")
	EndEvent

	Event OnDefaultST()
		iBars._setBarPressToToggle(activeBar, False)
		SetToggleOptionValueST(iBars._getBarPressToToggle(activeBar))
		SetToggleOptionValueST(iBars._getBarHoldToShow(activeBar), False, "BARHOLDTOSHOW")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Hotkey will toggle bar between visible and invisible with each press")
	EndEvent
EndState

State BARHOLDTOSHOW
	Event OnSelectST()
		iBars._setBarHoldToShow(activeBar, !iBars._getBarHoldToShow(activeBar))
		SetToggleOptionValueST(iBars._getBarHoldToShow(activeBar))
		SetToggleOptionValueST(iBars._getBarPressToToggle(activeBar), False, "BARPRESSTOTOGGLE")
	EndEvent

	Event OnDefaultST()
		iBars._setBarHoldToShow(activeBar, False)
		SetToggleOptionValueST(iBars._getBarHoldToShow(activeBar))
		SetToggleOptionValueST(iBars._getBarPressToToggle(activeBar), False, "BARPRESSTOTOGGLE")
	EndEvent

	Event OnHighlightST()
		SetInfoText("Hotkey will display bar while key is pressed and hide been when released")
	EndEvent
EndState

State POSITIONLOCK
	Event OnSelectST()
		pos_locked = !pos_locked
		SetToggleOptionValueST(pos_locked)
		if pos_locked
			min_pos_x = 0
			min_pos_y = 0
			max_pos_x = 1279
			max_pos_y = 719
		else
			min_pos_x = -10000
			min_pos_y = -10000
			max_pos_x = 10000
			max_pos_y = 10000
		EndIf
	EndEvent

	Event OnDefaultST()
		pos_locked = True
		min_pos_x = 0
		min_pos_y = 0
		max_pos_x = 1279
		max_pos_y = 719
		SetToggleOptionValueST(pos_locked)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Hotkey will display bar while key is pressed and hide been when released")
	EndEvent
EndState

Function _saveAllSettings()
	FISSInterface fiss = FISSFactory.getFISS()
	
	If !fiss
		Debug.MessageBox("FISSES not detected.  Saving unavailable.")
		return
	EndIf
	fiss.beginSave(SETTINGS_FILENAME, "iWant Status Bars")

	_saveAllBars(fiss)
	_saveAllIcons(fiss)
	_saveAllPositions(fiss)
	
	String saveResult = fiss.endSave()
	if saveResult != ""
		Debug.Trace(saveResult)
		Debug.MessageBox("Save Error")
		Debug.MessageBox(saveResult)
	Else
		Debug.MessageBox("Save Complete")
	EndIf
EndFunction

Function _loadAllSettings()
	FISSInterface fiss = FISSFactory.getFISS()
	
	If !fiss
		Debug.MessageBox("FISSES not detected.  Loading unavailable.")
		return
	EndIf
	fiss.beginLoad(SETTINGS_FILENAME)

	_loadAllBars(fiss)
	_loadAllIcons(fiss)
	_loadAllPositions(fiss)
	
	String loadResult = fiss.endLoad()
	if loadResult != ""
		Debug.Trace(loadResult)
		Debug.MessageBox("Load Error")
		Debug.MessageBox(loadResult)
	Else
		Debug.MessageBox("Load Complete")
	EndIf
EndFunction

Function _saveAllIcons(FISSInterface fiss)
	Int icon = 0
	
	While icon < iBars.TOTAL_ICONS
		_saveIcon(icon, fiss)
		icon += 1
	EndWhile
EndFunction

Function _loadAllIcons(FISSInterface fiss)
	Int icon = 0
	
	While icon < iBars.TOTAL_ICONS
		_loadIcon(icon, fiss)
		icon += 1
	EndWhile
EndFunction

Function _saveIcon(Int icon, FISSInterface fiss)
	String baseName = "Icon" + DELIMITER + iBars._getIconSourceModName(icon) + DELIMITER + iBars._getIconFriendlyName(icon) + DELIMITER
	String extendedBaseName
	Int s = 0
	
	While s < iBars.MAX_STATES_PER_ICON
		extendedBaseName = baseName + iBars._getIconStateName(icon, s) + DELIMITER

		fiss.saveInt(extendedBaseName + "RGB", iBars._getIconRGB(icon, s))
		fiss.saveInt(extendedBaseName + "Alpha", iBars._getIconAlpha(icon, s))

		s += 1
	EndWhile
EndFunction

Function _loadIcon(Int icon, FISSInterface fiss)
	If iBars.iconLabel[icon] == "No Icon - No Icon"
		return
	EndIf
	String baseName = "Icon" + DELIMITER + iBars._getIconSourceModName(icon) + DELIMITER + iBars._getIconFriendlyName(icon) + DELIMITER
	String extendedBaseName
	Int s = 0

	While s < iBars.MAX_STATES_PER_ICON
		extendedBaseName = baseName + iBars._getIconStateName(icon, s) + DELIMITER

		iBars._setIconRGB(icon, s, fiss.loadInt(extendedBaseName + "RGB"))
		iBars._setIconAlpha(icon, s, fiss.loadInt(extendedBaseName + "Alpha"))

		s += 1
	EndWhile
EndFunction

Function _saveAllBars(FISSInterface fiss)
	Int bar = 0
	
	While bar < iBars.TOTAL_STATUS_BARS
		_saveBar(bar, fiss)
		bar += 1
	EndWhile
EndFunction

Function _loadAllBars(FISSInterface fiss)
	Int bar = 0
	
	While bar < iBars.TOTAL_STATUS_BARS
		_loadBar(bar, fiss)
		bar += 1
	EndWhile
EndFunction

Function _saveBar(Int bar, FISSInterface fiss)
	String baseName = "Bar" + DELIMITER + bar + DELIMITER

	fiss.saveInt(baseName+"TypeIndex", iBars._getBarType(bar))
	fiss.saveInt(baseName+"X", iBars._getBarX(bar))
	fiss.saveInt(baseName+"Y", iBars._getBarY(bar))
	fiss.saveInt(baseName+"IconSize", iBars._getBarIconSize(bar))
	fiss.saveInt(baseName+"AutoHideTime", iBars._getBarAutoHideTime(bar))
	fiss.saveInt(baseName+"ActivationKey", iBars._getBarHotkey(bar))
	fiss.saveBool(baseName+"HideOnAlpha0", iBars._getBarHideOnAlpha0(bar))
	fiss.saveBool(baseName+"ShowOnChange", iBars._getBarShowOnChange(bar))
	fiss.saveBool(baseName+"PressToToggle", iBars._getBarPressToToggle(bar))
	fiss.saveBool(baseName+"HoldToShow", iBars._getBarHoldToShow(bar))
EndFunction

Function _loadBar(Int bar, FISSInterface fiss)
	String baseName = "Bar" + DELIMITER + bar + DELIMITER

	iBars._setBarType(bar, fiss.loadInt(baseName+"TypeIndex"))
	iBars._setBarX(bar, fiss.loadInt(baseName+"X"))
	iBars._setBarY(bar, fiss.loadInt(baseName+"Y"))
	iBars._setBarIconSize(bar, fiss.loadInt(baseName+"IconSize"))
	iBars._setBarHotkey(bar, fiss.loadInt(baseName+"ActivationKey"))
	iBars._setBarAutoHideTime(bar, fiss.loadInt(baseName+"AutoHideTime"))
	iBars._setBarHideOnAlpha0(bar, fiss.loadBool(baseName+"HideOnAlpha0"))
	iBars._setBarShowOnChange(bar, fiss.loadBool(baseName+"ShowOnChange"))
	iBars._setBarPressToToggle(bar, fiss.loadBool(baseName+"PressToToggle"))
	iBars._setBarHoldToShow(bar, fiss.loadBool(baseName+"HoldToShow"))
EndFunction

Function _saveAllPositions(FISSInterface fiss)
	Int bar = 0
	Int i = 0
	Int icon = 0

	While bar < iBars.TOTAL_STATUS_BARS
		i = 0
		While i < iBars.ICONS_PER_STATUS_BAR
			icon = iBars._getBarIcon(bar, i)
			_savePosition(bar, i, icon, fiss)
			i += 1
		EndWhile
		bar += 1
	EndWhile

EndFunction

Function _loadAllPositions(FISSInterface fiss)
	Int bar = 0
	Int i = 0
	Int icon = 0
	
	While bar < iBars.TOTAL_STATUS_BARS
		i = 0
		While i < iBars.ICONS_PER_STATUS_BAR
			_loadPosition(bar, i, fiss)
			i += 1
		EndWhile
		bar += 1
	EndWhile
EndFunction

Function _savePosition(Int bar, Int i, Int icon, FISSInterface fiss)
	String baseName = "Position" + DELIMITER + bar + DELIMITER + i

	fiss.saveInt(baseName, icon)
EndFunction

Function _loadPosition(Int bar, Int i, FISSInterface fiss)
	String baseName = "Position" + DELIMITER + bar + DELIMITER + i
	
	iBars._setBarIcon(bar, i, fiss.loadInt(baseName))
EndFunction

