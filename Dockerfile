FROM chatwoot/chatwoot:latest

# Copy patched widget assets (with ElevenLabs voice agent)
COPY custom-widget/assets/vite/ /app/public/vite/
