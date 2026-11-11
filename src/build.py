"""Builds Zelda-Ocarina-of-Time-Save-Editor.bat from editor.html, helper.ps1 and catalog.json.
Zelda Ocarina of Time Save Editor - by Ernani Zanandrea Dalzotto (https://github.com/ezdalzotto)
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
tpl=open(os.path.join(HERE,'editor.html'),encoding='utf-8').read()
cat=open(os.path.join(HERE,'catalog.json'),encoding='utf-8').read().replace('</','<\\/')
html=tpl.replace('/*CATALOG*/',cat)
ps=open(os.path.join(HERE,'helper.ps1'),encoding='utf-8').read()
header=('@echo off\n'
'rem Zelda Ocarina of Time Save Editor\n'
'rem Author: Ernani Zanandrea Dalzotto - https://github.com/ezdalzotto\n'
'rem Modifications are allowed as long as credit is given to the author.\n'
'setlocal\n'
'title Zelda Ocarina of Time Save Editor\n'
'set "OOT_SELF=%~f0"\n'
'powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -Command "$f=[IO.File]::ReadAllText($env:OOT_SELF,[Text.Encoding]::UTF8);$o=[StringComparison]::Ordinal;$a=$f.IndexOf(\'#PS\'+\'_BEGIN\',$o);$b=$f.IndexOf(\'#PS\'+\'_END\',$o);Invoke-Expression $f.Substring($a,$b-$a)"\n'
'if errorlevel 1 pause\n'
'exit /b\n')
for bad in ['#PS_BEGIN','#PS_END','#HTML_BEGIN']:
    assert bad not in header and bad not in html, bad
assert ps.count('#PS_BEGIN')==1 and ps.count('#PS_END')==1 and '#HTML_BEGIN' not in ps
assert all(ord(c)<128 for c in header+ps), 'non-ascii in bat/ps'
full=header+ps.rstrip('\n')+'\n#HTML_BEGIN\n'+html
full=full.replace('\r\n','\n').replace('\n','\r\n')
open(os.path.join(HERE,'..','Zelda-Ocarina-of-Time-Save-Editor.bat'),'wb').write(full.encode('utf-8'))
print('bat bytes',len(full.encode()))
