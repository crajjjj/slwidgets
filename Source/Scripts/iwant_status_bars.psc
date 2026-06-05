Scriptname iWant_Status_Bars extends Quest
{status management of iWant Widgets to generated persistent, mod driven, user-managed status bars}

iWant_Widgets Property iWidgets Auto

Import Utility

Bool barsInitialized = False
Bool barsReady = False
Int loadMessage = -1
Int Property _claimedBlankIcon = -1 Auto
Float version = 0.0
String DELIMITER = "|"


; Be careful with these constants
; We're using SKSE to get a big array of size (TOTAL_ICONS * MAX_FILES_PER_ICON)
; Documentation is light so unexpected results could occur as this value gets large
Int Property TOTAL_ICONS = 200 Auto
Int Property MAX_STATES_PER_ICON = 10 Auto
String[] iconFriendlyName
String[] iconSourceMod
String[] Property iconLabel Auto
String[] iconSourceFile
Int[]    iconActiveStatus
Bool[]   iconInUse
Int[]    iconWidget
Int[]    iconRed
Int[]    iconGreen
Int[]    iconBlue
Int[]    iconAlpha
String[] iconStateName

; Be careful with these constants
; We're using SKSE to get a big array of size (TOTAL_STATUS_BARS * ICONS_PER_STATUS_BAR)
; Documentation is light so unexpected results could occur as this value gets large
Int Property TOTAL_STATUS_BARS = 10 Auto
Int Property ICONS_PER_STATUS_BAR = 10 Auto
String[] Property AVAILABLE_BAR_TYPES Auto
Float    BAR_SPACING_PERCENTAGE = 1.5
Int[]    statusBarTypeIndex
Int[]    statusBarX
Int[]    statusBarY
Int[]    statusBarIconSize
Int[]    statusBarAutoHideTime
Bool[]   statusBarHideOnAlpha0
Bool[]   statusBarShowOnChange ; Should really have been called statusBarAutoHide
Int[]    statusBarIcon
Int[]    statusBarActivationKey
Bool[]   statusBarPressToToggle
Bool[]   statusBarHoldToShow
Bool[]   statusBarVisible
; SL Widgets patch: per-bar timestamp of last icon status change. Used by
; dependent mods to detect the autohide-faded state (the bar visibility
; flag stays True during autohide — only icon alpha fades — so this is
; the only signal available outside Flash).
Float[]  statusBarLastChangeTime

; Legacy variables
String   DEFAULT_STATUS_BAR_TYPE
String[] statusBarType

; Public functions

Int Function loadIcon(String sourceMod, String iconName, String[] stateNames, String[] files, Int[] r, Int[] g, Int[] b, Int[] a, Bool redraw = True)
{Loads icon information and places it into the next available bar position, returns -1 on no spots available, -2 on name combination in use}
	Int waitCount = 0
	While (!barsReady && waitCount < 1200)
		Wait(1.0)
		waitCount += 1
	EndWhile
	Int id
	Int i
	Int count
	Int w
	Int bar
	Int position
	
	If (_getIconID(sourceMod, iconName) == -1)
		id = _nextFreeIcon()
		If id >= 0
			iconInUse[id] = True
			iconSourceMod[id] = sourceMod
			iconFriendlyName[id] = iconName
			iconLabel[id] = iconName + " - " + sourceMod
			iconActiveStatus[id] = 0
			i = 0
			count = files.Length
			If count > MAX_STATES_PER_ICON
				count = MAX_STATES_PER_ICON
			EndIf
			While (i < count)
				_setIconSourceFile(id, i, files[i])
				_setIconRed(id, i, r[i])
				_setIconGreen(id, i, g[i])
				_setIconBlue(id, i, b[i])
				_setIconAlpha(id, i, a[i])
				If stateNames
					_setIconStateName(id, i, stateNames[i])
				EndIf
				i += 1
			EndWhile
			_loadIconWidgets(id)

			bar = _nextFreeBar()
			If bar >= 0
				position = _nextFreeBarPosition(bar)
				If position >= 0
					_setBarIcon(bar, position, id)
				EndIf
			EndIf
			
			_setIconStatusByID(id, 0, redraw)
		EndIf
	Else
		id = -2
	EndIf
	Return id
EndFunction

Function releaseIcon(String sourceMod, String name)
	Int id = _getIconID(sourceMod, name)

	If id != -1
		Int waitCount = 0
		While (!barsReady && waitCount < 1200)
			Wait(1.0)
			waitCount += 1
		EndWhile

		_releaseIconByID(id)
	EndIf
EndFunction

Function setIconStatus(String sourceMod, String name, Int status)
	Int id = _getIconID(sourceMod, name)
	Int bar

	If id != -1
		Int waitCount = 0
		While (!barsReady && waitCount < 1200)
			Wait(1.0)
			waitCount += 1
		EndWhile
		bar = _findBarOfIcon(id)
		
		; If icon is in a bar, size it properly, otherwise ensure it's offscreen
		If bar >= 0
			_resizeIconToBar(id, bar)
		Else
			_moveIconOffscreen(id)
		EndIf
		
		_setIconStatusByID(id, status)
	EndIf
EndFunction

Bool Function isReady()
	Return(barsReady)
EndFunction

; Internal functions

Function _setBarHotkey(Int bar, Int hotkey)
	Int oldHotkey = statusBarActivationKey[bar]
	
	UnregisterForKey(oldHotkey)
	statusBarActivationKey[bar] = hotkey
	If hotkey != -1
		RegisterForKey(hotkey)
	EndIf
EndFunction

Int Function _getBarHotkey(Int bar)
	Return(statusBarActivationKey[bar])
EndFunction

Function _setBarPressToToggle(Int bar, Bool setting)
	statusBarPressToToggle[bar] = setting
	If setting
		statusBarHoldToShow[bar] = False
	EndIf
EndFunction

Bool Function _getBarPressToToggle(Int bar)
	Return(statusBarPressToToggle[bar])
EndFunction

Function _setBarHoldToShow(Int bar, Bool setting)
	statusBarHoldToShow[bar] = setting
	If setting
		statusBarPressToToggle[bar] = False
	EndIf
EndFunction

Bool Function _getBarHoldToShow(Int bar)
	Return(statusBarHoldToShow[bar])
EndFunction

; SL Widgets patch: exposes current bar visibility so dependent mods can
; mirror it on their own widgets (e.g. NPC name labels that float above
; the bar should hide when the user toggles the bar off via hotkey).
Bool Function _getBarVisible(Int bar)
	Return(statusBarVisible[bar])
EndFunction

; SL Widgets patch: real-time timestamp of the bar's most recent icon
; status change. Returns 0.0 if no change has occurred since script
; init. Dependent mods compute autohide state as:
;   t > 0 && Utility.GetCurrentRealTime() > t + _getBarAutoHideTime(bar)
Float Function _getBarLastChangeTime(Int bar)
	Return(statusBarLastChangeTime[bar])
EndFunction

Function _iconSetVisible(Int icon, Bool vis)
	Int s = 0
	Int w
	
	If icon >=0
		While s < MAX_STATES_PER_ICON
			w = _getIconWidget(icon, s)

			iWidgets.setVisible(w, vis As Int)
			s += 1
		EndWhile
	EndIf
EndFunction

Int Function _findIconID(String sourceMod, String stateName)
	Bool found = False
	Int foundID = -1
	Int icon = 0
	
	While ((icon < TOTAL_ICONS) && (!found))
		If ((sourceMod == iconSourceMod[icon]) && (stateName == iconFriendlyName[icon]))
			foundID = icon
			found = True
		EndIf
		icon += 1
	EndWhile
	
	Return(foundID)
EndFunction

Int Function _findStateID(Int icon, String stateToFind)
	Bool found = False
	Int foundID = -1
	Int s = 0
	
	While ((s < MAX_STATES_PER_ICON) && (!found))
		If (stateToFind == _getIconStateName(icon, s))
			foundID = s
			found = True
		EndIf
		s += 1
	EndWhile
	
	Return(foundID)
EndFunction

Int Function _findBarOfIcon(Int icon)
{Returns the bar the specified bar resides in of -1 if the icon cannot be found in a bar}
	; This is what you have to write when the data model wasn't fully fleshed out before coding
	Int foundID = -1
	Bool found = False
	
	Int bar = 0
	Int position
	
	While bar < TOTAL_STATUS_BARS && !found
		position = 0
		While position < ICONS_PER_STATUS_BAR && !found
			If _getBarIcon(bar, position) == icon
				foundID = bar
				found = True
			EndIf
			position += 1
		EndWhile
		bar += 1
	EndWhile
	
	Return(foundID)
EndFunction

Function _setBarAutoHideTime(Int bar, Int t)
	statusBarAutoHideTime[bar] = t
EndFunction

Int Function _getBarAutoHideTime(Int bar)
	Return(statusBarAutoHideTime[bar])
EndFunction

Function _setBarShowOnChange(Int bar, Bool s)
	statusBarShowOnChange[bar] = s
EndFunction

Bool Function _getBarShowOnChange(Int bar)
	Return(statusBarShowOnChange[bar])
EndFunction

Function _setBarHideOnAlpha0(Int bar, Bool s)
	statusBarHideOnAlpha0[bar] = s
EndFunction

Bool Function _getBarHideOnAlpha0(Int bar)
	Return(statusBarHideOnAlpha0[bar])
EndFunction

Function _setBarX(Int bar, Int x)
	statusBarX[bar] = x
EndFunction

Function _setBarY(Int bar, Int y)
	statusBarY[bar] = y
EndFunction

Function _setBarType(Int bar, Int type)
	statusBarTypeIndex[bar] = type
EndFunction

Function _setBarIconSize(Int bar, Int size)
	statusBarIconSize[bar] = size
EndFunction

Int Function _getBarX(Int bar)
	Return (statusBarX[bar])
EndFunction

Int Function _getBarY(Int bar)
	Return (statusBarY[bar])
EndFunction

Int Function _getBarType(Int bar)
	Return (statusBarTypeIndex[bar])
EndFunction

Int Function _getBarIconSize(Int bar)
	Return (statusBarIconSize[bar])
EndFunction

Function _drawAllBars()
	Int b = 0

	While b < TOTAL_STATUS_BARS
		_drawBar(b)
		b += 1
	EndWhile
EndFunction

String Function _getIconFriendlyName(Int icon)
	Return(iconFriendlyName[icon])
EndFunction

String Function _getIconSourceModName(Int icon)
	Return(iconSourceMod[icon])
EndFunction

String Function _getIconLabel(Int icon)
	Return(iconLabel[icon])
EndFunction

Int Function _getIconID(String mod, String name)
{Return id icon associated with the given mod and friendly name or -1 if not found}
	Int i
	Bool found = False
	Int foundID = -1
	
	i = 0
	While ((i < TOTAL_ICONS) && (!found))
		If ((mod == iconSourceMod[i]) && (name == iconFriendlyName[i]))
			found = True
			foundID = i
		EndIf
		i += 1
	EndWhile

	Return(foundID)	
EndFunction

Function _releaseIconByID(Int id, Bool redraw = True)
{Clears an icon, freeing it for future use}
	Int i
	Int w
	
	If iconInUse[id]
		iconSourceMod[id] = ""
		iconFriendlyName[id] = ""
		iconLabel[id] = "No Icon - No Icon"
		iconActiveStatus[id] = 0
		i = 0
		While (i < MAX_STATES_PER_ICON)
			w = _getIconWidget(id, i)
			_setIconSourceFile(id, i, "")
			_setIconWidget(id, i, -1)
			_setIconRed(id, i, 0)
			_setIconGreen(id, i, 0)
			_setIconBlue(id, i, 0)
			_setIconAlpha(id, i, 0)
			_setIconStateName(id, i, "")
			If iWidgets
				iWidgets.destroy(w)
			EndIf
			i += 1
		EndWhile
		iconInUse[id] = False
	EndIf
	If redraw
		_drawAllBars()
	EndIf
EndFunction

Function _setIconStatusByID(Int id, Int status, Bool redraw = True)
{Sets the active status to be used by the status bar}
	Int w
	Int bar = _findBarOfIcon(id)
	Bool change = False
	Int autohideTime = 0
	
	; If the icon changed, fade out the last state
	If status != iconActiveStatus[id]
		w = _getIconWidget(id, iconActiveStatus[id])
		If w >= 0
			iWidgets.doTransition(w, 0, 15)
		EndIf
		change = True
	EndIf
	
	; Is icon in an auto-hiding bar?
	If bar >= 0
		If statusBarShowOnChange[bar]
			autohideTime = statusBarAutoHideTime[bar]
		EndIf
		; SL Widgets patch: record the time of the most recent icon change
		; so dependent mods can detect when an autohide-mode bar has faded
		; out (statusBarVisible stays True; only widget alpha fades).
		If change
			statusBarLastChangeTime[bar] = Utility.GetCurrentRealTime()
		EndIf
	EndIf
	
	iconActiveStatus[id] = status
	w = _getIconWidget(id, iconActiveStatus[id])
	Int targetAlpha = _getIconAlpha(id, status)

	If w >= 0
		iWidgets.setRGB(w, _getIconRed(id, status), _getIconGreen(id, status), _getIconBlue(id, status))
		; Set alpha to 1 before drawAllBars so hideOnAlpha0 does not skip positioning.
		; Only on state change — the incoming widget may have been at 0. Skipping this on
		; no-change calls prevents a visible pulse (snap-to-1 + fade-to-target every tick).
		If (targetAlpha > 0) && change
			iWidgets.setTransparency(w, 1)
		EndIf
	EndIf

	If redraw
		_drawAllBars()
	EndIf

	If w >= 0
		; Display unless we're auto-hiding and there was no change
		If (autohideTime == 0) || change
			iWidgets.doTransition(w, targetAlpha, 30)
		EndIf
	EndIf

	; Stage fade out if we're auto-hiding and there was a change
	If (autohideTime > 0) && change
		_hideIcon(id, (autohideTime * 30))
	EndIf
EndFunction

Function _loadMessage(String msg)
	If loadMessage >= 0
		_destroyLoadMessage()
	EndIf
	loadMessage = iWidgets.loadText(msg)
	iWidgets.setTransparency(loadMessage, 0)
	iWidgets.setPos(loadMessage, 1280/2, 640)
	iWidgets.setVisible(loadMessage)
	iWidgets.doTransition(loadMessage, 100, 60)
EndFunction

Function _destroyLoadMessage()
	iWidgets.doTransition(loadMessage, 0, 30)
	Wait(0.5)
	iWidgets.destroy(loadMessage)
EndFunction

Function _drawBar(Int bar)
{Draws the designated status bar based on current settings}
	Int[] widgetList
	Int i
	Int icon
	Int change
	Int radius
	Bool inUse
	Int activeState
	Int startAngle = 0
	Int iconCount = 0
	
	widgetList = CreateIntArray(ICONS_PER_STATUS_BAR, -1)
	i = 0
	While i < ICONS_PER_STATUS_BAR
		icon = _getBarIcon(bar, i)
		
		;Scrub bar while we draw, if icon has been released clean up the position
		If icon >= 0
			If !iconInUse[icon]
				_setBarIcon(bar, i, -1)
				icon = -1
			EndIf
		EndIf

		If icon >= 0
			_iconSetVisible(icon, statusBarVisible[bar])
			widgetList[i] = _getIconWidget(icon, iconActiveStatus[icon])
			iconCount += 1
		Else
			widgetList[i] = -1
		EndIf
		i += 1
	EndWhile

	If iconCount > 0
		If (statusBarTypeIndex[bar] < 4 ) ; Line types
			change = (statusBarIconSize[bar] * BAR_SPACING_PERCENTAGE) As Int
			If (statusBarTypeIndex[bar] == 0) ; To the left
				iWidgets.drawShapeLine(widgetList, statusBarX[bar], statusBarY[bar], 0 - change, 0, True, statusBarHideOnAlpha0[bar])
			ElseIf (statusBarTypeIndex[bar] == 1) ; To the right
				iWidgets.drawShapeLine(widgetList, statusBarX[bar], statusBarY[bar], change, 0, True, statusBarHideOnAlpha0[bar])
			ElseIf (statusBarTypeIndex[bar] == 2) ; Upward
				iWidgets.drawShapeLine(widgetList, statusBarX[bar], statusBarY[bar], 0, 0 - change, True, statusBarHideOnAlpha0[bar])
			ElseIf (statusBarTypeIndex[bar] == 3) ; Downward
				iWidgets.drawShapeLine(widgetList, statusBarX[bar], statusBarY[bar], 0, change, True, statusBarHideOnAlpha0[bar])
			EndIf	
		ElseIf statusBarTypeIndex[bar] == 4 ; Circle
			radius = (statusBarIconSize[bar] As Float * 2.0) As Int
			iWidgets.drawShapeCircle(widgetList, statusBarX[bar], statusBarY[bar], radius, 0, 360, True, statusBarHideOnAlpha0[bar], True)
		ElseIf statusBarTypeIndex[bar] == 5 ; Orbit
			radius = (statusBarIconSize[bar] As Float * 2.0) As Int
			iWidgets.setSize(widgetList[0], statusBarIconSize[bar] * 2, statusBarIconSize[bar] * 2)
			iWidgets.drawShapeOrbit(widgetList, statusBarX[bar], statusBarY[bar], radius, 0, 360, True, statusBarHideOnAlpha0[bar], True)
		ElseIf statusBarTypeIndex[bar] > 5 ; Half circles
			radius = (statusBarIconSize[bar] As Float * 3.0) As Int
			If (statusBarTypeIndex[bar] == 6) ; Lower half circle
				startAngle = 0
			ElseIf (statusBarTypeIndex[bar] == 7) ; Upper half circle
				startAngle = 180
			ElseIf (statusBarTypeIndex[bar] == 8) ; Left half circle
				startAngle = 90
			ElseIf (statusBarTypeIndex[bar] == 9) ; Right half circle
				startAngle = 270
			EndIf	
			iWidgets.drawShapeCircle(widgetList, statusBarX[bar], statusBarY[bar], radius, startAngle, 180, True, statusBarHideOnAlpha0[bar], True)
		EndIf
	EndIf
EndFunction

Function _loadIconWidgets(Int id)
	Int i = 0
	Int w
	String sourceFile
	
	While i < MAX_STATES_PER_ICON
		sourceFile = _getIconSourceFile(id, i)
		If sourceFile != ""
			w = iWidgets.loadWidget(sourceFile)
			If _getIconAlpha(id, 0) > 0
				iWidgets.setTransparency(w, 1)
			Else
				iWidgets.setTransparency(w, 0)
			EndIf
			iWidgets.setVisible(w, 1)
		Else
			w = -1
		EndIf
		_setIconWidget(id, i, w)
		i += 1
	EndWhile
EndFunction

Function _resetIconVisibility(Int icon)
{Force sets all states to the appropriate alpha and color}
	Int i = 0
	Int w
	While i < MAX_STATES_PER_ICON
		w = _getIconWidget(icon, i)
		If w >= 0
			iWidgets.doTransition(w, 0, 15)
			iWidgets.setRGB(w, _getIconRed(icon, i), _getIconGreen(icon, i), _getIconBlue(icon, i)) 
		EndIf
		i += 1
	EndWhile
	_setIconStatusByID(icon, iconActiveStatus[icon])
EndFunction

Function _resizeAllBars()
	Int i = 0
	
	While i < TOTAL_STATUS_BARS
		_resizeBar(i)
		i += 1
	EndWhile
EndFunction

Function _resizeBar(Int bar)
	Int i = 0
	
	While i < ICONS_PER_STATUS_BAR
		_resizeIconToBar(_getBarIcon(bar, i), bar)
		i += 1
	EndWhile
EndFunction

Function _resizeIconToBar(Int icon, Int bar)
{Resize the icon to the specified bar's current size}
	Int i = 0
	Int w
	Int size
	
	If ((_getBarIcon(bar, 0) == icon) && (statusBarTypeIndex[bar] == 5)) ; This icon is the center icon of an Orbit
		size = statusBarIconSize[bar] * 2
	Else 
		size = statusBarIconSize[bar]
	EndIf
	
	If icon >= 0
		While i < MAX_STATES_PER_ICON
			w = _getIconWidget(icon, i)
			If w >= 0
				iWidgets.setSize(w, size, size)
			EndIf
			i += 1
		EndWhile
	EndIf
EndFunction

Function _clearBarPosition(Int bar, Int position)
	_setBarIcon(bar, position, -1)
EndFunction

Int Function _nextFreeBar()
{Return id of next bar with available positions or -1 if no spots remain}
	Int i
	Bool found = False
	Int foundID = -1
	
	i = 0
	While ((i < TOTAL_STATUS_BARS) && (!found))
		If _nextFreeBarPosition(i) != -1
			found = True
			foundID = i
		EndIf
		i += 1
	EndWhile

	Return(foundID)
EndFunction	

Int Function _nextFreeBarPosition(Int bar)
{Return id of next available position in the specified bar or -1 if no spots remain}
	Int i
	Bool found = False
	Int foundID = -1
	
	i = 0
	While ((i < ICONS_PER_STATUS_BAR) && (!found))
		; The following if was updated to treat the claimed blank icon as an open spots
		; See _claimBlankIcon for an explanation of why this became necessary
		If ((_getBarIcon(bar, i) < 0) || (_getBarIcon(bar, i) == _claimedBlankIcon))
			found = True
			foundID = i
		EndIf
		i += 1
	EndWhile

	Return(foundID)
EndFunction	

Int Function _nextFreeIcon()
{Return id of next available icon status or -1 if no icon spots remain}
	Int i
	Bool found = False
	Int foundID = -1
	
	i = 0
	While ((i < TOTAL_ICONS) && (!found))
		If !iconInUse[i]
			found = True
			foundID = i
		EndIf
		i += 1
	EndWhile

	Return(foundID)
EndFunction	

Int Function _getIconRGB(Int icon, Int status)
	Int r = _getIconRed(icon, status)
	Int g = _getIconGreen(icon, status)
	Int b = _getIconBlue(icon, status)
	Int rgb = (r * 256 * 256) + (g * 256) + b
	Return(rgb)
EndFunction

Function _setIconRGB(Int icon, Int status, Int rgb)
	Int r = rgb / (256 * 256)
	rgb -= (r * 256 *256)
	Int g = rgb / 256
	rgb -= (g * 256)
	Int b = rgb
	
	_setIconRed(icon, status, r)
	_setIconGreen(icon, status, g)
	_setIconBlue(icon, status, b)
EndFunction

Function _setIconRed(Int icon, Int status, Int r)
{Sets the red value of a given icon at the specified status}
	_setBigArrayInt(iconRed, icon, status, MAX_STATES_PER_ICON, r)
EndFunction

Int Function _getIconRed(Int icon, Int status)
{Returns the red value of a given icon at the specified status}
	Return(_getBigArrayInt(iconRed, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconGreen(Int icon, Int status, Int g)
{Sets the green value of a given icon at the specified status}
	_setBigArrayInt(iconGreen, icon, status, MAX_STATES_PER_ICON, g)
EndFunction

Int Function _getIconGreen(Int icon, Int status)
{Returns the green value of a given icon at the specified status}
	Return(_getBigArrayInt(iconGreen, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconBlue(Int icon, Int status, Int b)
{Sets the blue value of a given icon at the specified status}
	_setBigArrayInt(iconBlue, icon, status, MAX_STATES_PER_ICON, b)
EndFunction

Int Function _getIconBlue(Int icon, Int status)
{Returns the blue value of a given icon at the specified status}
	Return(_getBigArrayInt(iconBlue, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconAlpha(Int icon, Int status, Int a)
{Sets the alpha value of a given icon at the specified status}
	_setBigArrayInt(iconAlpha, icon, status, MAX_STATES_PER_ICON, a)
EndFunction

Int Function _getIconAlpha(Int icon, Int status)
{Returns the alpha value of a given icon at the specified status}
	Return(_getBigArrayInt(iconAlpha, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconStateName(Int icon, Int status, String name)
{Sets the state name of a given icon at the specified status}
	_setBigArrayString(iconStateName, icon, status, MAX_STATES_PER_ICON, name)
EndFunction

String Function _getIconStateName(Int icon, Int status)
{Returns the state name of a given icon at the specified status}
	Return(_getBigArrayString(iconStateName, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconSourceFile(Int icon, Int status, String file)
{Sets the source file of the given icon at the specified status}
	_setBigArrayString(iconSourceFile, icon, status, MAX_STATES_PER_ICON, file)
EndFunction

String Function _getIconSourceFile(Int icon, Int status)
{Returns the source file of the given icon at the specified status}
	Return(_getBigArrayString(iconSourceFile, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setIconWidget(Int icon, Int status, Int widget)
{Sets the widget value of a given icon at the specified status}
	_setBigArrayInt(iconWidget, icon, status, MAX_STATES_PER_ICON, widget)
EndFunction

Int Function _getIconWidget(Int icon, Int status)
{Returns the widget value of a given icon at the specified status}
	Return(_getBigArrayInt(iconWidget, icon, status, MAX_STATES_PER_ICON))
EndFunction

Function _setBarIcon(Int bar, Int position, Int icon)
{Sets the icon value of a given bar at the specified position}
	Int b = 0
	Int i
	; Icon can exist in only one location, clear it from others
	While  b < TOTAL_STATUS_BARS
		i = 0
		While i < ICONS_PER_STATUS_BAR
			If _getBarIcon(b, i) == icon
				_setBigArrayInt(statusBarIcon, b, i, ICONS_PER_STATUS_BAR, -1)
			EndIf
			i += 1
		EndWhile
		b += 1
	EndWhile
	_setBigArrayInt(statusBarIcon, bar, position, ICONS_PER_STATUS_BAR, icon)
	_resizeIconToBar(icon, bar)
EndFunction

Function _hideIcon(Int Icon, Int delay = 0)
{Set all widgets to alpha 0}
	Int i = 0
	Int w
	While i < MAX_STATES_PER_ICON
		w = _getIconWidget(icon, i)
		If w >= 0
			iWidgets.doTransition(w, 0, 15, delay = delay)
		EndIf
		i += 1
	EndWhile
EndFunction

Function _moveIconOffscreen(Int Icon)
{Set all widgets to a position out of view}
	Int i = 0
	Int w
	While i < MAX_STATES_PER_ICON
		w = _getIconWidget(icon, i)
		If w >= 0
			iWidgets.setPos(w, 10000, 10000)
		EndIf
		i += 1
	EndWhile
EndFunction

Function _hideBar(Int bar)
{Set all widgets in a bar to alpha 0}
	Int i = 0
	Int w
	While i < ICONS_PER_STATUS_BAR
		w = _getBarIcon(bar, i)
		If w >= 0
			_hideIcon(w)
		EndIf
		i += 1
	EndWhile
EndFunction

Int Function _getBarIcon(Int bar, Int position)
{Returns the icon value of a given bar at the specified position}
	Return(_getBigArrayInt(statusBarIcon, bar, position, ICONS_PER_STATUS_BAR))
EndFunction

String Function _getBigArrayString(String[] array, Int x, Int y, Int max_x)
{Calculates and returns the value at a location in a faked multidimensional array}
	Return(array[(x * max_x)+y])
EndFunction

Function _setBigArrayString(String[] array, Int x, Int y, Int max_x, String value)
{Set the value at a location in a faked multidimensional array}
	array[(x * max_x)+y] = value
EndFunction

Int Function _getBigArrayInt(Int[] array, Int x, Int y, Int max_x)
{Calculates and returns the value at a location in a faked multidimensional array}
	Int value = array[(x * max_x)+y]
	Return(value)
EndFunction

Function _setBigArrayInt(Int[] array, Int x, Int y, Int max_x, Int value)
{Set the value at a location in a faked multidimensional array}
	Int loc = (x * max_x)+y
	array[loc] = value
EndFunction

Function _initializeStatusBars()
{Initialize status bar arrays when mod is first initialized}
	; Legacy variable
	;statusBarType = CreateStringArray(TOTAL_STATUS_BARS, DEFAULT_STATUS_BAR_TYPE)
	statusBarTypeIndex = CreateIntArray(TOTAL_STATUS_BARS, 0)
	statusBarX = CreateIntArray(TOTAL_STATUS_BARS, 0)
	statusBarY = CreateIntArray(TOTAL_STATUS_BARS, 0)
	statusBarIconSize = CreateIntArray(TOTAL_STATUS_BARS, 50)
	statusBarActivationKey = CreateIntArray(TOTAL_STATUS_BARS, -1)
	statusBarAutoHideTime = CreateIntArray(TOTAL_STATUS_BARS, 30)
	statusBarHideOnAlpha0 = CreateBoolArray(TOTAL_STATUS_BARS, True)
	statusBarShowOnChange = CreateBoolArray(TOTAL_STATUS_BARS, False)
	statusBarPressToToggle = CreateBoolArray(TOTAL_STATUS_BARS, False)
	statusBarHoldToShow =  CreateBoolArray(TOTAL_STATUS_BARS, False)
	statusBarVisible = CreateBoolArray(TOTAL_STATUS_BARS, True)
	statusBarLastChangeTime = Utility.CreateFloatArray(TOTAL_STATUS_BARS, 0.0)
	statusBarIcon =  CreateIntArray(TOTAL_STATUS_BARS * ICONS_PER_STATUS_BAR, -1)
	
	; Start bars in bottom right corner
	Int x = 1210
	Int y = 650
	Int size = 25
	Int xspacing = 0
	Int yspacing = (0.0 - (size As Float * BAR_SPACING_PERCENTAGE)) As Int
	Int type = 0
	Int i
	
	_initializeBarTypes()
	
	While i < TOTAL_STATUS_BARS
		_setBarX(i, x)
		_setBarY(i, y)
		_setBarIconSize(i, size)
		_setBarType(i, type)
		_setBarShowOnChange(i, False)
		_setBarAutoHideTime(i, 30)
		_setBarPressToToggle(i, False)
		_setBarHoldToShow(i, False)
		_setBarHotkey(i, -1)
		x += xspacing
		y += yspacing
		i += 1
	EndWhile
EndFunction

Function _initializeBarTypes()
	AVAILABLE_BAR_TYPES = new String[10]
	AVAILABLE_BAR_TYPES[0] = "Line extending to the left"
	AVAILABLE_BAR_TYPES[1] = "Line extending to the right"
	AVAILABLE_BAR_TYPES[2] = "Line extending up"
	AVAILABLE_BAR_TYPES[3] = "Line extending down"
	AVAILABLE_BAR_TYPES[4] = "Circle"
	AVAILABLE_BAR_TYPES[5] = "Orbit"
	AVAILABLE_BAR_TYPES[6] = "Lower half circle"
	AVAILABLE_BAR_TYPES[7] = "Upper half circle"
	AVAILABLE_BAR_TYPES[8] = "Left half circle"
	AVAILABLE_BAR_TYPES[9] = "Right half circle"

	DEFAULT_STATUS_BAR_TYPE = AVAILABLE_BAR_TYPES[0]
EndFunction

Function _initializeIcons()
{Initialize icon arrays when mod is first initialized}
	Int i

	iconFriendlyName = CreateStringArray(TOTAL_ICONS, fill = "")
	iconSourceMod = CreateStringArray(TOTAL_ICONS, fill = "")
	iconLabel = CreateStringArray(TOTAL_ICONS, fill = "")
	iconInUse = CreateBoolArray(TOTAL_ICONS, fill = False)
	iconActiveStatus = CreateIntArray(TOTAL_ICONS, fill = 0)
	iconRed = CreateIntArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = 0)
	iconGreen = CreateIntArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = 0)
	iconBlue = CreateIntArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = 0)
	iconAlpha = CreateIntArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = 0)
	iconSourceFile = CreateStringArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = "")
	iconWidget = CreateIntArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = -1)
	iconStateName = CreateStringArray(TOTAL_ICONS * MAX_STATES_PER_ICON, fill = "")
	
	; Create*Array doesn't seem to initialize properly
	i = 0
	While i < TOTAL_ICONS
		_releaseIconByID(i, redraw = False)
		i += 1
	EndWhile
EndFunction

Function _claimBlankIcon()
	; This is sort of hack
	; Initially -1 meant no icon but that breaks as an array index in the MCM
	; This was added to make the MCM fairly easy to deal with
	; _nextFreeBarPosition was updated to scrub these to free slots as needed
	Int[] n
	String[] s
	
	n = new Int[1]
	n[0] = 0
	s = new String[1]
	s[0] = ""
	
	_claimedBlankIcon = loadIcon("No Icon", "No Icon", s, s, n, n, n, n, redraw = False)
EndFunction

Event OnInit()
	RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
EndEvent

Function _versionUpdate(Int ver)
{A different (better?) version control method triggered by SkyUI in MCM code}
	If ver == 3
		Debug.Trace("iWant Status Bars:  Upgrading to 2.04")
		; Setup new array to support hotkey usage
		; _drawBar will check this and toggle the widget's properties based on it
		statusBarVisible = CreateBoolArray(TOTAL_STATUS_BARS, True)
	EndIf
EndFunction

Function GameLoad()
	Debug.Trace("iWant Status Bars: Game load detected")
	RegisterForModEvent("iWantWidgetsReset", "OniWantWidgetsReset")
EndFunction

Event OniWantWidgetsReset(String eventName, String strArg, Float numArg, Form sender)
	Int i

	If eventName == "iWantWidgetsReset"
		barsReady = False
		iWidgets = sender As iWant_Widgets
		Debug.Trace("iWant Status Bars Version " + version)
		If version < 1.1
			; Version 1.0 had some pretty significant issues
			; Initialize the arrays and start from scratch
			Debug.Trace("iWant Status Bars: Upgrading to Version 1.1")
			Debug.Trace("Reinitializing arrays")
			barsInitialized = False
			version = 1.1
		EndIf
		If version < 2.03
			Debug.Trace("iWant Status Bars: Upgrading to Version 2.03")
			; Reset these so the match new defaults
			If barsInitialized
				i = 0
				While i < TOTAL_STATUS_BARS
					statusBarAutoHideTime[i] = 30
					statusBarShowOnChange[i] = False
					i += 1
				EndWhile
			EndIf
			version = 2.03
		EndIf
		If barsInitialized
			Debug.Trace("iWant Status Bars: Loading Icons")
			; _loadMessage("iWant Status Bars: Loading Icons")
			i = 0
			While i < TOTAL_ICONS
				_loadIconWidgets(i)
				_setIconStatusByID(i, iconActiveStatus[i], redraw = False)
				i += 1
			EndWhile
			; _loadMessage("iWant Status Bars: Resizing Bars")
			_resizeAllBars()
		Else
			Debug.Trace("iWant Status Bars: Initializing Icons")
			; _loadMessage("iWant Status Bars: Initializing Icons")
			_initializeStatusBars()
			_initializeIcons()
			barsInitialized = True
		EndIf
		barsReady = True
		If _claimedBlankIcon == -1
			_claimBlankIcon()
		EndIf
		_destroyLoadMessage()
		_drawAllBars()
		Debug.Trace("iWant Status Bars: Bars Ready")
		RegisterForModEvent("iWantStatusBarsReady", "OniWantStatusBarsReady")
		SendModEvent("iWantStatusBarsReady")
	EndIf
EndEvent

Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == "iWantStatusBarsReady"
		Debug.Trace("iWant Status Bars: Bars Ready Event Received")
	EndIf
EndEvent

Event OnKeyDown(Int KeyCode)
	Int bar = 0
	
	While bar < TOTAL_STATUS_BARS
		; We only care about keys if one of these is turned on
		If statusBarPressToToggle[bar] || statusBarHoldToShow[bar]
			; Is it a key this bar cares about?
			If KeyCode == statusBarActivationKey[bar]
				If statusBarHoldToShow[bar]
					statusBarVisible[bar] = True
				ElseIf statusBarPressToToggle[bar]
					statusBarVisible[bar] = !statusBarVisible[bar]
				EndIf
				_drawBar(bar)
			EndIf
		EndIf
		bar += 1
	EndWhile
EndEvent

Event OnKeyUp(Int KeyCode, Float HoldTime)
	Int bar = 0
	
	While bar < TOTAL_STATUS_BARS
		; We only care about keys if this is turned on
		If statusBarHoldToShow[bar]
			; Is it a key this bar cares about?
			If KeyCode == statusBarActivationKey[bar]
				statusBarVisible[bar] = False
				_drawBar(bar)
			EndIf
		EndIf
		bar += 1
	EndWhile
EndEvent

