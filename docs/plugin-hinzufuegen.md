# Ein Plugin hinzufügen

Kurzfassung: **eine Zeile in `plugins.json`, ein Absatz in der README.** Alles andere passiert von
selbst. Hintergrund in [wie der Index funktioniert](wie-der-index-funktioniert.md).

## Voraussetzungen an das Plugin

Bevor es aufgenommen werden kann, muss dreierlei stimmen:

1. **Das Repository ist öffentlich.** Dalamud lädt ohne Anmeldung; privat ergäbe bei Nutzern einen
   404.
2. **Es gibt mindestens ein veröffentlichtes Release** (kein Entwurf, keine Vorabversion).
3. **An diesem Release hängt das gepackte ZIP** — das, was DalamudPackager erzeugt und das das
   Plugin-Manifest enthält. Heißt es `latest.zip`, wird es automatisch gefunden.

Mehr ist nicht nötig. Insbesondere braucht das Plugin-Repository **keinen** Workflow, keine
Zusatzdatei und keine Kenntnis davon, dass dieser Index existiert.

## Schritt 1 — eintragen

In `plugins.json`:

```json
[
  { "repo": "miralsoft/Dalamud-Eorzea-Arsenal" },
  { "repo": "miralsoft/Neues-Plugin" }
]
```

Optional pro Eintrag:

| Feld | Bedeutung |
| --- | --- |
| `asset` | Der zu verwendende Anhang, falls ein Release mehrere ZIPs hat. |
| `acceptsFeedback` | Ob Dalamud die Feedback-Schaltfläche anbietet. Standard `true`. |

## Schritt 2 — vorstellen

In der [README](../README.md) einen Abschnitt nach dem Muster der vorhandenen anlegen: Überschrift
mit dem Namen, ein fetter Satz, was das Plugin tut, ein paar Stichpunkte, und die Links zum
Plugin-Repository und gegebenenfalls zur Webseite.

Die README ist die **Nutzerseite**. Sie erklärt nicht, wie dieses Verzeichnis funktioniert — dafür
sind diese Dokumente da.

Denk daran: Was Dalamud **im Spiel** anzeigt, kommt aus dem Manifest des Plugins, nicht aus dieser
README. Liest sich die Beschreibung im Spiel schlecht, gehört die Verbesserung ins Plugin-Repository.

## Schritt 3 — prüfen

Der Push auf `main` startet den Index-Workflow sofort (er reagiert auf Änderungen an
`plugins.json`). Danach:

- Unter *Actions* → *Index* muss der Lauf **grün** sein. Rot heißt: mindestens ein Plugin ließ sich
  nicht auflösen — die Ursache steht im Protokoll des Schritts *Build index*.
- In `pluginmaster.json` muss das neue Plugin mit `InternalName`, `AssemblyVersion`,
  `DalamudApiLevel` und einem Download-Link stehen, in dem ein **Tag** vorkommt (nicht `latest`).

Lokal vorab testen geht auch:

```powershell
./scripts/build-index.ps1
```

## Häufige Ursachen, wenn es nicht klappt

| Meldung | Ursache |
| --- | --- |
| `404` | Repository privat, Name falsch geschrieben, oder es gibt noch kein Release. |
| `release '…' has no assets` | Das Release hat keine Anhänge — das ZIP fehlt. |
| `no plugin manifest found inside …` | Im ZIP liegt keine Manifest-Datei; vermutlich wurde nicht mit DalamudPackager gepackt. |
| `has N zip assets` | Mehrere ZIPs am Release — den gewünschten über `asset` benennen. |

## Ein Plugin wieder entfernen

Zeile aus `plugins.json` löschen. Beim nächsten Lauf verschwindet der Eintrag aus dem Index — und
damit **bei allen Nutzern aus der Plugin-Liste**. Das ist der einzige Weg, wie ein Eintrag
absichtlich verschwindet; ein Fehler beim Abruf tut das ausdrücklich nicht.

## Zur Adresse

Aktuell dokumentiert und bei Nutzern eingetragen:

```
https://xivarsenal.app/plugin.json
```

Geplant ist, zusätzlich `plugins.json` (Mehrzahl) anzubieten und diese künftig zu dokumentieren, weil
sie mehrere Plugins besser beschreibt. **`plugin.json` bleibt dauerhaft bestehen** — Nutzer haben sie
eingetragen, und eine Alt-Adresse abzuschalten würde ihnen die Plugins aus der Liste nehmen. Erst
wenn die neue Route nachweislich live ist, wird sie hier und in der README zur genannten Adresse.
