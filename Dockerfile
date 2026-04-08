FROM chatwoot/chatwoot:latest

# Build arguments for ElevenLabs configuration
ARG VITE_ELEVENLABS_AGENT_ID=agent_6601kc1fqeecfc88s7d52jde0syq
ARG VITE_ELEVENLABS_VOICE_ID=
ARG VITE_ELEVENLABS_AGENT_NAME=AI Assistant

# Set environment variables for build
ENV VITE_ELEVENLABS_AGENT_ID=${VITE_ELEVENLABS_AGENT_ID}
ENV VITE_ELEVENLABS_VOICE_ID=${VITE_ELEVENLABS_VOICE_ID}
ENV VITE_ELEVENLABS_AGENT_NAME=${VITE_ELEVENLABS_AGENT_NAME}

# ── Backend patches (Ruby / ERB) ─────────────────────────────────────────────
# Patch web_widget model: adds elevenlabs_voice feature flag (bit 5) + elevenlabs_agent_id attr
COPY custom-widget/patches/web_widget.rb /app/app/models/channel/web_widget.rb

# Patch widget view: exposes enableElevenLabsVoice + elevenLabsAgentId to window.chatwootWebChannel
COPY custom-widget/patches/show.html.erb /app/app/views/widgets/show.html.erb

# Patch inbox API response: exposes elevenlabs_agent_id to the admin UI
COPY custom-widget/patches/_inbox.json.jbuilder /app/app/views/api/v1/models/_inbox.json.jbuilder

# Patch inboxes controller: permit new params
COPY custom-widget/patches/inboxes_controller.rb /app/app/controllers/api/v1/accounts/inboxes_controller.rb

# Patch admin UI: add ElevenLabs settings to Configuration page
COPY custom-widget/patches/ConfigurationPage.vue /app/app/javascript/dashboard/routes/dashboard/settings/inbox/settingsPage/ConfigurationPage.vue

# Database migration: adds elevenlabs_agent_id column to channel_web_widgets
COPY custom-widget/patches/20260408000001_add_elevenlabs_to_channel_web_widgets.rb \
     /app/db/migrate/20260408000001_add_elevenlabs_to_channel_web_widgets.rb

# ── Widget source overrides (compiled during image build) ─────────────────────
# Keep the image deterministic: always compile the widget/dashboard assets with
# our overrides baked in (no need to commit built bundles to git).
COPY custom-widget/components/ChatInputWrap.vue /app/app/javascript/widget/components/ChatInputWrap.vue
COPY custom-widget/components/ElevenLabsVoiceButton.vue /app/app/javascript/widget/components/ElevenLabsVoiceButton.vue
COPY custom-widget/store/index.js /app/app/javascript/widget/store/index.js
COPY custom-widget/store/modules/appConfig.js /app/app/javascript/widget/store/modules/appConfig.js
COPY custom-widget/store/modules/elevenlabsVoice.js /app/app/javascript/widget/store/modules/elevenlabsVoice.js
COPY custom-widget/patches/configMixin.js /app/app/javascript/widget/mixins/configMixin.js
COPY custom-widget/i18n/en.json /app/app/javascript/widget/i18n/en.json

# Build Vite assets so /public/vite contains the latest JS/CSS.
# The upstream base image may not ship with postcss-import, so add it.
RUN cd /app && pnpm add -D postcss-import
RUN cd /app && NODE_OPTIONS=--max-old-space-size=4096 node /app/node_modules/vite/bin/vite.js build

# Add labels for metadata
LABEL org.opencontainers.image.title="Chatwoot with ElevenLabs Voice"
LABEL org.opencontainers.image.description="Chatwoot custom image with ElevenLabs voice integration (per-inbox toggle)"
LABEL elevenlabs.agent_id="${VITE_ELEVENLABS_AGENT_ID}"
