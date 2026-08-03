# Wie der Index funktioniert

Interne Beschreibung dieses Repositories. Für Nutzer ist die [README](../README.md) gedacht.

## Was das hier ist

Dalamud erlaubt es, eigene Plugin-Quellen einzutragen — *Custom Plugin Repositories*. Technisch ist
eine solche Quelle nur **eine URL, die eine JSON-Datei ausliefert**. Diese Datei ist ein
**JSON-Array**; jedes Element beschreibt ein Plugin mit Name, Version, Beschreibung, Icon und einem
Download-Link auf das fertig gepackte ZIP. Dalamud zeigt jeden Eintrag als installierbares Plugin an.

Dieses Repository ist genau diese Liste — **ein Verzeichnis, kein Plugin**. Es enthält keinen
Plugin-Quellcode, baut nichts und veröffentlicht keine Releases. Jedes Plugin bleibt ein eigenes
Repository mit eigenen Releases; hier stehen nur Verweise auf Dateien, die dort **bereits
existieren**.

## Die Adresskette

```
https://xivarsenal.app/plugin.json
        └── liefert ───► raw.githubusercontent.com/miralsoft/Dalamud-Plugins/main/pluginmaster.json
                                └── verweist ───► auf die Releases der einzelnen Plugin-Repos
```

Die Domain steht bewusst davor: Die Adresse gehört uns, nicht GitHub. Wird dieses Repository je
umbenannt, verschoben oder ersetzt, ändert sich hinter der Domain nur das Ziel — kein Nutzer muss je
wieder etwas anfassen. Deshalb ist die Domain die offizielle Adresse und dieses Repository
austauschbar.

## Die Dateien

| Datei | Bedeutung |
| --- | --- |
| `plugins.json` | **Die einzige von Hand gepflegte Datei.** Die Liste der Quell-Repositories. |
| `scripts/build-index.ps1` | Baut daraus den Index. |
| `.github/workflows/index.yml` | Führt das Skript stündlich, auf Knopfdruck und bei Änderungen aus. |
| `pluginmaster.json` | **Erzeugt — niemals von Hand bearbeiten.** Das ist, was Dalamud liest. |
| `README.md` | Für Nutzer: Vorstellung der Plugins. |
| `docs/` | Für uns: dieses Dokument und die Anleitung zum Hinzufügen. |

## Der Ablauf

Für jedes Repository in `plugins.json`:

1. Das **neueste veröffentlichte Release** wird über die GitHub-API abgefragt.
2. Dessen ZIP wird geladen und das darin enthaltene Plugin-Manifest ausgelesen — Name, Version,
   Beschreibung, `DalamudApiLevel`, Icon, Tags: alles, was Dalamud dem Spieler anzeigt.
3. Die Download-Links werden auf **genau dieses Release** gesetzt.
4. Alles wird zu einem Array zusammengesetzt und committet.

Das Auslesen aus dem ZIP ist der entscheidende Kniff: **Das Quell-Repository muss nichts tun.** Kein
Workflow, keine Zusatzdatei, keine Kenntnis davon, dass dieser Index existiert. Jedes Dalamud-Plugin,
das sein gepacktes ZIP als Release-Asset anhängt, lässt sich aufnehmen.

## Regeln, die nicht gebrochen werden dürfen

Jede Verletzung führt dazu, dass Plugins bei **allen** Nutzern aus der Liste verschwinden oder sich
nicht mehr installieren lassen.

1. **`pluginmaster.json` nie von Hand ändern.** Sie wird erzeugt; eine Handänderung ist beim nächsten
   Lauf weg — oder bleibt und ist falsch.
2. **Die öffentliche Adresse nie ändern.** Nutzer haben sie eingetragen.
3. **Die Datei muss ein JSON-Array bleiben** (`[ … ]`), auch bei genau einem Eintrag. Ein einzelnes
   Objekt lehnt Dalamud ab.
4. **Kein BOM** am Dateianfang — Dalamuds Parser lehnt ihn ab. In PowerShell deshalb
   `[System.IO.File]::WriteAllText` mit `UTF8Encoding($false)`; `Set-Content -Encoding utf8` und
   `Out-File -Encoding utf8` erzeugen unter Windows PowerShell 5.1 einen BOM.
5. **Download-Links zeigen auf einen festen Tag, nie auf `/releases/latest/`.** „Latest" heißt „das
   neueste Release im ganzen Repository" — solange dort ein Plugin liegt harmlos, ab dem zweiten
   falsch. Das Skript macht das korrekt; bitte nicht „vereinfachen".
6. **Ein Plugin, das gerade nicht erreichbar ist, behält seinen bisherigen Eintrag.** Siehe unten.
7. **Quell-Repositories müssen öffentlich sein.** Dalamud lädt ohne Anmeldung; ein privates
   Repository ergäbe bei Nutzern einen 404.
8. **Kein Plugin-Code in dieses Repository.**

## Warum ein Fehler nichts löscht

Kann ein Repository nicht gelesen werden, übernimmt das Skript dessen **bisherigen Eintrag**. Das
sieht im Code nach nachlässiger Fehlerbehandlung aus und ist das genaue Gegenteil: Etwas nicht lesen
zu können ist kein Beleg dafür, dass es weg ist. Würde der Eintrag verschwinden, nähme Dalamud das
Plugin bei **jedem** Nutzer aus der Liste — wegen einer schlechten Minute bei GitHub.

Der Lauf wird trotzdem rot, damit jemand hinschaut. Ist gar nichts auflösbar, bleibt die Datei
unangetastet, statt mit einer leeren Liste überschrieben zu werden.

**Diese Logik bitte nicht „aufräumen".**

## Testen

Im Wurzelverzeichnis:

```powershell
./scripts/build-index.ps1
```

Danach prüfen: Beginnt die Datei mit `[`? Hat jeder Eintrag `InternalName`, `AssemblyVersion`,
`DalamudApiLevel` und einen Download-Link mit einem Tag darin?

**Eine Falle, die schon einmal zugeschlagen hat:** In Windows PowerShell 5.1 sammelt
`@( ConvertFrom-Json … )` die *Pipeline-Ausgabe*, und 5.1 reicht ein JSON-Array als **ein** Objekt
durch — die Klammern machen daraus eine einelementige Liste, und eine Schleife über zwei Plugins
läuft einmal mit beiden verschmolzen. Bei genau einem Plugin fällt das nie auf. Deshalb steht im
Skript überall erst eine Zuweisung und dann `@($variable)`. Beim Testen immer mit **mindestens zwei**
Einträgen prüfen.

## Was Nutzer wo sehen

Ein häufiges Missverständnis: **Was Dalamud im Spiel anzeigt, kommt nicht aus der README dieses
Repositories.** Name, Kurzbeschreibung (`Punchline`), Beschreibung, Icon und Tags liest Dalamud aus
dem Manifest, das jedes Plugin in seinem eigenen ZIP mitbringt.

- Soll sich ein Plugin **im Spiel** besser vorstellen → das gehört ins Manifest des jeweiligen
  Plugin-Repositories.
- Die README hier richtet sich an **Menschen auf GitHub**. Ein Tippfehler darin bricht nichts.
