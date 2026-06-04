Scriptname iwant_widgets_native hidden

;loading
Int Function LoadMeter(String asRoot,Int aiXPos, Int aiYPos, Bool abVisible) global native
Int Function LoadText(String asRoot, String asDisplayString, String asFont, Int asSize, Int aiXpos, Int asYpos, Bool asVisible) global native
Int Function LoadWidget(String asRoot,String asFilename, Int aiXpos, Int aiYpos, Bool abVisible) global native

;generic
Function SetPos(String asRoot, Int aiId, Int aiXpos, Int aiYpos) global native
Function SetPosX(String asRoot, Int aiId, Int aiXpos) global native
Function SetPosY(String asRoot, Int aiId, Int aiYpos) global native
Function SetSize(String asRoot, Int aiId, Int aiH, Int aiW) global native
Function SetSizeH(String asRoot, Int aiId, Int aiH) global native
Function SetSizeW(String asRoot, Int aiId, Int aiW) global native
Int Function GetSize(String asRoot, Int aiId, Int aiType) global native
Function SetZoom(String asRoot, Int aiId, Int aiScaleX, Int aiScaleY) global native
Function SetZoomX(String asRoot, Int aiId, Int aiScaleX) global native
Function SetZoomY(String asRoot, Int aiId, Int aiScaleY) global native
Function SetVisible(String asRoot, Int aiId, Int aiVisible) global native
Function SetRotation(String asRoot, Int aiId, Int aiRotation) global native
Function SetTransparency(String asRoot, Int aiId, Int aiAlpha) global native
Function SetRGB(String asRoot, Int aiId, Int aiRed, Int aiGreen, Int aiBlue) global native
Function Destroy(String asRoot, Int aiId) global native
Function SwapDepths(String asRoot, Int aiId1, Int aiId2) global native

;meters
Function SetMeterPercent(String asRoot,Int aiId, Int aiPercent) global native
Function SetMeterFillDirection(String asRoot,Int aiId, String asDirection) global native
Function SendToBack(String asRoot,Int aiId) global native
Function SendToFront(String asRoot,Int aiId) global native
Function DoMeterFlash(String asRoot, Int aiId) global native
Function SetMeterRGB(String asRoot, Int aiId, Int aiLightR, Int aiLightG, Int aiLightB, Int aiDarkR, \
                        Int aiDarkG, Int aiDarkB, Int aiFlashR, Int aiFlashG, Int aiFlashB) global native

;text
Function SetText(String asRoot, Int aiId, String asDisplayString) global native
Function AppendText(String asRoot, Int aiId, String asDisplayString) global native

;drwaw
Function DrawShapeLine(String asRoot, Int[] aaList, Int aiXPos, Int aiYPos, Int aiXChange, Int aiYChange, Bool abSkipInvisible, Bool abSkipAlpha0) global native
Function DrawShapeCircle(String asRoot, Int[] aaList, Int aiXPos, Int aiYPos, Int aiRadius, Int aiStartAngle, Int aiDegreeChange, Bool abSkipInvisible, Bool abSkipAlpha0, Bool abAutoSpace) global native
Function DrawShapeOrbit(String asRoot, Int[] aaList, Int aiXPos, Int aiYPos, Int aiRadius, Int aiStartAngle, Int aiDegreeChange, Bool abSkipInvisible, Bool abSkipAlpha0, Bool abAutoSpace) global native

;transition
Function DoTransitionByTime(String asRoot, Int aiId, Int aiTargetValue, Float afSeconds, String asTargetAttribute, String asEasingClass, String asEasingMethod, Float afDelay) global native

;other
bool Function IsHudReady()              global native
     Function Reset(String asRoot)      global native
bool Function IsResetting()             global native
String Function GetOutput(Int aiId, String asDef) global native