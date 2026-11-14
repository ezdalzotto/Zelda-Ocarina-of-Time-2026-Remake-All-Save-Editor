# Zelda Ocarina of Time 2026 Remake Save Editor

Save editor for the **2026 remake** of **Zelda: Ocarina of Time** (Nintendo Switch 2) **on PC**. It edits the save files used by the emulator on your Windows computer.

> ⚠️ Only for the **2026 remake**. It does **not** work with the original N64 game, Ocarina of Time 3D or PC ports such as Ship of Harkinian.

**By Ernani Zanandrea Dalzotto** — [github.com/ezdalzotto](https://github.com/ezdalzotto)

🇧🇷 [Leia em português](#português)

![Zelda Ocarina of Time 2026 Remake Save Editor](docs/screenshot.png)

---

## Download

Download **[Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html](Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html)** (open the file and click **Download raw file**). It is a single page that runs in your browser: nothing to install.

Works with **any emulator and any save folder**.

## How to use

1. **Stop the game in your emulator** (Emulation → Stop).
2. Open the save folder: in the emulator, right-click the game → **Open Save Data Location**, then open the slot folder (`slot_00`, `slot_01`…).
3. Open the `.html` file in your browser and drag `progress.sav` and `caption.sav` into it (or click **Choose progress.sav and caption.sav…**).
4. Edit and click **Save**. Your original files are downloaded first as a backup (`backup_*.sav`).
5. **Copy the edited `progress.sav` and `caption.sav` back into the same slot folder**, replacing the old ones. If the browser renamed them (e.g. `progress (1).sav`), rename them first.
6. Start the game and load the slot.

In Chrome/Edge you can also choose **Write directly into a folder…** to skip the copy step (does not work for folders inside `AppData`, which the browser blocks).

The interface is available in **English** and **Portuguese** (EN/PT buttons in the top-right corner).

The save folder usually ends with `…\user\save\0000000000000000\<user id>\0400486024DEC000\slot_XX`. Where it is depends on your emulator.

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

- **Automatic backup:** every time you save, your original files are downloaded first as `backup_<slot>_<date>_progress.sav` / `caption.sav`.
- Everything runs in your browser. Nothing is installed and nothing is sent to the internet.

## How it works

Field names in the save are MurmurHash3 (x86, 32-bit, seed 0) hashes. Source code is in [`src/`](src): `editor.html` (interface), `catalog.json` (field list) and `build.py` (generates the final `.html`).

## License

MIT License. You may use, modify and redistribute it **as long as you keep the credit to Ernani Zanandrea Dalzotto** ([github.com/ezdalzotto](https://github.com/ezdalzotto)). See [LICENSE](LICENSE).

Unofficial fan tool, not affiliated with Nintendo. Always keep a backup of your save.

---

## Português

Editor de save do **remake de 2026** de **Zelda: Ocarina of Time** (Nintendo Switch 2) **para PC**. Edita os arquivos de save usados pelo emulador no seu computador com Windows.

> ⚠️ Somente para o **remake de 2026**. **Não** funciona com o jogo original de N64, com o Ocarina of Time 3D nem com ports para PC como o Ship of Harkinian.

**Por Ernani Zanandrea Dalzotto** — [github.com/ezdalzotto](https://github.com/ezdalzotto)

### Download

Baixe o **[Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html](Zelda-Ocarina-of-Time-2026-Remake-Save-Editor.html)** (abra o arquivo e clique em **Download raw file**). É uma página única que roda no navegador: não precisa instalar nada.

Funciona com **qualquer emulador e qualquer pasta de save**.

### Como usar

1. **Pare o jogo no emulador** (Emulação → Parar).
2. Abra a pasta do save: no emulador, clique com o botão direito no jogo → **Abrir local dos dados salvos** e entre na pasta do slot (`slot_00`, `slot_01`…).
3. Abra o arquivo `.html` no navegador e arraste o `progress.sav` e o `caption.sav` para ele (ou clique em **Escolher progress.sav e caption.sav…**).
4. Edite e clique em **Salvar**. Os arquivos originais são baixados antes, como backup (`backup_*.sav`).
5. **Copie o `progress.sav` e o `caption.sav` editados de volta para a mesma pasta do slot**, substituindo os antigos. Se o navegador renomeou (ex.: `progress (1).sav`), renomeie antes.
6. Abra o jogo e carregue o slot.

No Chrome/Edge também dá para escolher **Gravar direto numa pasta…** e pular a cópia (não funciona em pastas dentro do `AppData`, que o navegador bloqueia).

A interface está em **inglês** e **português** (botões EN/PT no canto superior direito); ela sempre abre em inglês.

A pasta do save normalmente termina em `…\user\save\0000000000000000\<id do usuário>\0400486024DEC000\slot_XX`. O local depende do emulador.

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

- **Backup automático:** toda vez que você salva, os arquivos originais são baixados antes como `backup_<slot>_<data>_progress.sav` / `caption.sav`.
- Tudo roda no navegador. Nada é instalado e nada é enviado para a internet.

### Licença

Licença MIT. Você pode usar, modificar e redistribuir **desde que mantenha o crédito a Ernani Zanandrea Dalzotto** ([github.com/ezdalzotto](https://github.com/ezdalzotto)). Veja o arquivo [LICENSE](LICENSE).

Ferramenta de fã, não oficial e sem ligação com a Nintendo. Sempre guarde um backup do seu save.
