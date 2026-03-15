# DUSTHAVEN — Sound Tracker

> Suivi de génération des sons — Résultats et validations

## Sons validés

| ID | Nom | Tentative | Statut | Notes |
|----|-----|-----------|--------|-------|
| VOX-001 | Marteau forge Gustave | #1 | ✅ VALIDÉ | 8s, mono, -11.9dB, 88KB. |
| AMB-002 | Rivière / ruisseau | #1 | ✅ LIVRÉ | 60s, mono, -12.2dB, 731KB. En attente feedback. |
| AMB-003 | Cascade | #1 | ✅ LIVRÉ | 45s, mono, -12.0dB, 465KB. En attente feedback. |
| AMB-004 | Village Dusthaven | #1 | ✅ LIVRÉ | 60s, mono, 637KB. En attente feedback. |

## Sons à refaire

| ID | Nom | Tentative | Problème | Action |
|----|-----|-----------|----------|--------|
| AMB-001 | Vent désert général | #1 | Trop faible — "on entend rien" (Moncef) | Regénérer avec niveau plus élevé (-6dB peak) |

## Sons en cours de génération

| ID | Nom | Statut |
|----|-----|--------|
| SFX-001 | Batée — plonger dans l'eau | #1 | ✅ VALIDÉ | 1.58s, mono, -11.9dB peak, 17KB. ElevenLabs /v1/sound-generation + ffmpeg. |

## Sons en attente

Tous les P0 restants puis P1/P2 (voir SOUND_INDEX_Z1.md)

## Leçons apprises

- LRN-SND-001 : Les sons d'ambiance subtils (vent) à -12dB peak sont TROP faibles. Utiliser -6dB peak pour les ambiances à faible dynamique.
- LRN-SND-002 : ElevenLabs Sound Effects API limite à 22-30s max. Pour les sons plus longs, loop via ffmpeg.
- LRN-SND-003 : 1 son par spawn parallèle >> batch séquentiel (le batch de 5 en 1 session a timeout à 30min).
