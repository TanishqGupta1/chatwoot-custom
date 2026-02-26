FROM chatwoot/chatwoot:latest

# Copy patched widget assets (with ElevenLabs voice agent)
COPY custom-widget/assets/vite/ /app/public/vite/

# Copy voice config (agents.json + admin UI + API)
COPY voice-config/ /app/public/voice-config/
