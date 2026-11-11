# Zelda Ocarina of Time 2026 Remake Save Editor

Save editor for the **2026 remake** of **Zelda: Ocarina of Time** (Nintendo Switch 2) **on PC**. It edits the save files used by the emulator on your Windows computer.

> ⚠️ Only for the **2026 remake**. It does **not** work with the original N64 game, Ocarina of Time 3D or PC ports such as Ship of Harkinian.

**By Ernani Zanandrea Dalzotto** — [github.com/ezdalzotto](https://github.com/ezdalzotto)

🇧🇷 [Leia em português](#português)

![Zelda Ocarina of Time 2026 Remake Save Editor](docs/screenshot.png)

---

## Download

Download **[Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat](Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat)** (open the file and click **Download raw file**). It is a single file: nothing to install.

Requirements: Windows 10 or 11 (uses the built-in PowerShell) and any modern browser.

## How to use

1. **Stop the game in the emulator** (Emulation → Stop). The game keeps the save in memory and overwrites the file when it saves again or quits.
2. Double-click `Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat`. A black window opens (keep it open) and the editor opens in your browser.
3. Click the save folder that was found, or locate it manually (**Browse for progress.sav…** or paste the path).
4. **Choose the slot.** Compare hearts, rupees, location and date with what the game shows. In-game "Slot 1" may be the `slot_00` folder.
5. Edit and click **Save to game**.
6. Start the game again and load the slot.

The interface is available in **English** and **Portuguese** (EN/PT buttons in the top-right corner).

The editor finds the save folder automatically. It usually looks like:
`%APPDATA%\<emulator>\nand\user\save\0000000000000000\<your user id>\0400486024DEC000`
(in the emulator: right-click the game → Open Save Data Location).

## Features

- Rupees and wallet, heart containers, current hearts, magic meter and magic
- Ammo and bag/quiver sizes, magic beans, Gold Skulltula tokens, pieces of heart
- Items and equipment: swords, shields, tunics, boots, masks, upgrades, stones and medallions, magic, trading items
- The 12 ocarina songs plus the Scarecrow's Song
- Bottles and their contents, small keys per dungeon
- Visited places, minigame records and counters, Giant's Knife durability
- Event flags and an advanced editor with every field of `progress.sav` (~12,000)
- Voice language (`option.sav`)
- Shortcuts: full hearts/magic, fill wallet, refill ammo, max bags, all songs

## Safety

- **Automatic backups** before every save in `Downloads\Zelda OoT Save Editor - Backups`, with a **Restore** button in the Backups tab.
- After writing, the helper reads the file back from disk and checks that it matches what was sent.
- Warns when the game seems to be running in the emulator.
- Everything runs on your computer. The helper only listens on `127.0.0.1`, uses a random token per session and only reads and writes `progress.sav`, `caption.sav` and `option.sav`. Nothing is sent to the internet.

**Manual mode:** if you prefer, use **Pick files manually…**. The edited files are downloaded and you copy them back into the slot folder.

**Windows warning:** files downloaded from the internet may show "Windows protected your PC". Click **More info → Run anyway**.

## How it works

Browsers cannot write inside `AppData`, so the `.bat` starts a small PowerShell helper that serves the editor at `http://127.0.0.1` and does the reading and writing. Field names in the save are MurmurHash3 (x86, 32-bit, seed 0) hashes.

Source code is in [`src/`](src): `editor.html` (interface), `helper.ps1` (local helper), `catalog.json` (field list) and `build.py` (generates the `.bat`).

## License

MIT License. You may use, modify and redistribute it **as long as you keep the credit to Ernani Zanandrea Dalzotto** ([github.com/ezdalzotto](https://github.com/ezdalzotto)). See [LICENSE](LICENSE).

Unofficial fan tool, not affiliated with Nintendo. Always keep a backup of your save.

---

## Português

Editor de save do **remake de 2026** de **Zelda: Ocarina of Time** (Nintendo Switch 2) **para PC**. Edita os arquivos de save usados pelo emulador no seu computador com Windows.

> ⚠️ Somente para o **remake de 2026**. **Não** funciona com o jogo original de N64, com o Ocarina of Time 3D nem com ports para PC como o Ship of Harkinian.

**Por Ernani Zanandrea Dalzotto** — [github.com/ezdalzotto](https://github.com/ezdalzotto)

### Download

Baixe o **[Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat](Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat)** (abra o arquivo e clique em **Download raw file**). É um único arquivo: não precisa instalar nada.

Requisitos: Windows 10 ou 11 (usa o PowerShell que já vem no sistema) e qualquer navegador atual.

### Como usar

1. **Pare o jogo no emulador** (Emulação → Parar). O jogo guarda o save na memória e grava por cima do arquivo quando salva de novo ou ao sair.
2. Dê dois cliques no `Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.bat`. Abre uma janela preta (deixe aberta) e o editor aparece no navegador.
3. Clique na pasta de saves encontrada ou localize manualmente (**Procurar o progress.sav…** ou cole o caminho).
4. **Escolha o slot.** Compare corações, rupias, local e data com o que o jogo mostra. O "Slot 1" do jogo pode ser a pasta `slot_00`.
5. Edite e clique em **Salvar no jogo**.
6. Abra o jogo de novo e carregue o slot.

A interface está em **inglês** e **português** (botões EN/PT no canto superior direito); ela sempre abre em inglês.

O editor encontra a pasta de saves sozinho. Normalmente ela é parecida com:
`%APPDATA%\<emulador>\nand\user\save\0000000000000000\<id do seu usuário>\0400486024DEC000`
(no emulador: botão direito no jogo → Abrir local dos dados salvos).

### Recursos

- Rupias e carteira, corações máximos, corações atuais, medidor de magia e magia
- Munição e tamanho das bolsas/aljava, feijões mágicos, tokens de Skulltula Dourada, pedaços de coração
- Itens e equipamentos: espadas, escudos, túnicas, botas, máscaras, melhorias, pedras e medalhões, magias, itens de troca
- As 12 canções da ocarina e a Canção do Espantalho
- Garrafas e conteúdo, chaves pequenas por masmorra
- Locais visitados, recordes de minigames e contadores, durabilidade da Faca do Gigante
- Flags de eventos e editor avançado com todos os campos do `progress.sav` (~12 mil)
- Idioma das vozes (`option.sav`)
- Atalhos: corações/magia cheios, encher carteira, encher munição, bolsas no máximo, todas as canções

### Segurança

- **Backup automático** antes de cada gravação em `Downloads\Zelda OoT Save Editor - Backups`, com botão **Restaurar** na aba Backups.
- Depois de gravar, o ajudante relê o arquivo do disco e confere se ficou igual ao que foi enviado.
- Avisa quando o jogo parece estar rodando no emulador.
- Tudo roda no seu computador. O ajudante só escuta em `127.0.0.1`, usa uma chave aleatória por sessão e só lê e grava `progress.sav`, `caption.sav` e `option.sav`. Nada é enviado para a internet.

**Modo manual:** se preferir, use **Escolher arquivos manualmente…**. Os arquivos editados são baixados e você os copia de volta para a pasta do slot.

**Aviso do Windows:** arquivos baixados da internet podem mostrar "O Windows protegeu o computador". Clique em **Mais informações → Executar assim mesmo**.

### Licença

Licença MIT. Você pode usar, modificar e redistribuir **desde que mantenha o crédito a Ernani Zanandrea Dalzotto** ([github.com/ezdalzotto](https://github.com/ezdalzotto)). Veja o arquivo [LICENSE](LICENSE).

Ferramenta de fã, não oficial e sem ligação com a Nintendo. Sempre guarde um backup do seu save.
