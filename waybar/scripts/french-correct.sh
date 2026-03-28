#!/usr/bin/env bash
# Grab selected text, correct French, auto-paste result

MODEL="mistral-nemo"
BLOB="/var/lib/ollama/blobs/sha256-b559938ab7a0392fc9ea9675b82280f2a15669ec3e0e0fc491c9cb0a7681cf94"
NOTIFY_ID_FILE="/tmp/french-correct-notify-id"

# Get selected text
INPUT=$(wl-paste --primary 2>/dev/null)

if [[ -z "$INPUT" ]]; then
  notify-send -u low "French Correct" "Aucun texte sélectionné"
  exit 1
fi

# Show processing notification
notify-send -u low -t 10000 -p "French Correct" "Correction en cours..." > "$NOTIFY_ID_FILE" 2>/dev/null

PROMPT="Corrige uniquement les fautes d'orthographe et de grammaire dans ce texte français. Retourne UNIQUEMENT le texte corrigé, sans explication, sans guillemets, sans rien d'autre.

Texte: $INPUT"

# Call Mistral, unload immediately after
RESULT=$(ollama run --keepalive 0 "$MODEL" "$PROMPT" 2>/dev/null)

if [[ -z "$RESULT" ]]; then
  notify-send -u normal "French Correct" "Erreur: pas de réponse du modèle"
  exit 1
fi

# Copy result and paste
echo -n "$RESULT" | wl-copy
sleep 0.1
ydotool key ctrl+v

# Close processing notification and confirm
PREV_ID=$(cat "$NOTIFY_ID_FILE" 2>/dev/null)
notify-send -u low -t 3000 "French Correct" "✓ Corrigé"
