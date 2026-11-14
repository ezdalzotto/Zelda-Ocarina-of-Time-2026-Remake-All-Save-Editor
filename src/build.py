"""Builds Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html from editor.html and catalog.json.
Zelda Ocarina of Time 2026 Remake Save Editor - by Ernani Zanandrea Dalzotto (https://github.com/ezdalzotto)
"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
tpl = open(os.path.join(HERE, 'editor.html'), encoding='utf-8').read()
cat = open(os.path.join(HERE, 'catalog.json'), encoding='utf-8').read().replace('</', '<\\/')
html = tpl.replace('/*CATALOG*/', cat)
out = os.path.join(HERE, '..', 'Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html')
open(out, 'w', encoding='utf-8', newline='\n').write(html)
print('html bytes', len(html.encode()))
