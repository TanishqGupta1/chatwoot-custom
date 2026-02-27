FROM chatwoot/chatwoot:latest

# Build arguments for ElevenLabs configuration
ARG VITE_ELEVENLABS_AGENT_ID=agent_6601kc1fqeecfc88s7d52jde0syq
ARG VITE_ELEVENLABS_VOICE_ID=
ARG VITE_ELEVENLABS_AGENT_NAME=AI Assistant

# Set environment variables for build
ENV VITE_ELEVENLABS_AGENT_ID=${VITE_ELEVENLABS_AGENT_ID}
ENV VITE_ELEVENLABS_VOICE_ID=${VITE_ELEVENLABS_VOICE_ID}
ENV VITE_ELEVENLABS_AGENT_NAME=${VITE_ELEVENLABS_AGENT_NAME}

# Copy patched widget assets (with ElevenLabs voice agent)
COPY custom-widget/assets/vite/ /app/public/vite/

# Add labels for metadata
LABEL org.opencontainers.image.title="Chatwoot with ElevenLabs Voice"
LABEL org.opencontainers.image.description="Chatwoot custom image with ElevenLabs voice integration"
LABEL elevenlabs.agent_id="${VITE_ELEVENLABS_AGENT_ID}"
