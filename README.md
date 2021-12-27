SexLab Widgets SSE
=======================

A  plugin for iWant Status Bars to add sexlab related widgets to Skyrim. Supports 2 mechanics
- Icons that have 9 stages and change dynamically
- Icons that appear/dissapear on condition
113 icons included.
MCM for flexible configuration


Supported plugins and icons: 

Stages (constantly showing status):
- vSLA SE (SexLab Aroused eXtended/SLAM) - Arousal (face) and exposure (Heart) icons
- vApropos2 - w&t icons (vagina, anus and mouth state icons)
- vFill her up - cum icons (total + vaginal + anal pool icons)
- MME - milk (breast) and lactacid (bottle) icons
- PAF and MiniNeeds - piss (bladder) and poop (colon) icons

Toggles (appear on condition only):
- SexLab-Parasite - spider eggs, chaurus worms (when infected)
- Pregnancy: HentaiPregnancy, BeeingFemale, EggFactory, EstrusChaurus, EstrusSpider, EstrusDwemer, FM3  - cum inflation(spermatozoids icon)/ovulation (ovulation egg icon) /pregnancy (different icons belly based - fetus/eggs/spider eggs/spheres)
- Defeat: SLDefeat - weakened (raped) - hands on body icon




Installation

- Install as any other mod. SE version is esl based. (LE version - esp works for SE as well)

- (Optional) Flexible icon configuration via SLWidgets MCM 

- (Optional) Save SLWidget properties via MCM (autopreload for new saves - inspired by Settings Loader Series)

- (Optional) Configure icon placement/color/size in iWant Status Bars MCM. You can use multiple bars as well

- (Optional) Use custom icons packs from download section. Just install as any other mode (dds icons only)



Hard Requirements

iWant Status Bars
iWant Widgets
PapyrusUtil


Soft Dependencies

Sexlab Aroused SE (any version will do, including SLAX)
Apropos2 SE
Fill her up 
Fertility Mod 3
HentaiPregnancy
BeeingFemale
EggFactory
SexLab-Parasite
EstrusChaurus
EstrusSpider
EstrusDwemer
PAF
MiniNeeds
SLDefeat

Troubleshooting
- Check console messages
- Check papyrus logs and slwidgets user logs
- Check mcm debug page and dependency check
- Try to disable/enable plugin (widgets are reloaded on menu close event)
- Check ibars menu - if icons were added or not
- Check the load order iwidgets->ibars->slwidgets

Incompatible mods:

Affected indirectly by mods that impact iWant Widgets.  Mods significantly altering hudmenu.gfx directly or via a hudmenu.swf file may prevent image display.

Tested in different mod lists with multiple UI mods (Tsukiro/D&DDC/Licentia)



Customization:

You can use your own icons. To do that put them into mod -  \Interface\exported\widgets\iwant\widgets\library\.. folders. Just follow the naming convention already in place.

Supported icon format is .dds. Image size 100x100. 

To convert you can use Gimp (pick bc3 compression/no mipmaps when exporting to dds).



Notes on LE installation

LE version of the iWant Status Bars/iWant Widgets is included in the fomod of the SE version. 

