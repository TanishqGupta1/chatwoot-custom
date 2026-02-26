<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'ElevenLabsVoiceButton',
  props: {
    color: {
      type: String,
      default: '#1f93ff',
    },
    size: {
      type: String,
      default: 'medium',
    },
  },
  data() {
    return {
      showVoiceModal: false,
      isConnecting: false,
      isCallActive: false,
      scriptLoaded: false,
    };
  },
  computed: {
    ...mapGetters({
      elevenLabsEnabled: 'appConfig/getElevenLabsEnabled',
      elevenLabsConfig: 'appConfig/getElevenLabsConfig',
    }),
    shouldShowButton() {
      return this.elevenLabsEnabled && this.elevenLabsConfig?.agentId;
    },
    buttonClasses() {
      const sizeClasses = {
        small: 'min-h-6 min-w-6',
        medium: 'min-h-8 min-w-8',
        large: 'min-h-10 min-w-10',
      };
      return [
        'elevenlabs-voice-btn flex items-center justify-center rounded-full transition-all duration-200 cursor-pointer border-0 bg-transparent p-1',
        sizeClasses[this.size] || sizeClasses.medium,
        this.isCallActive ? 'elevenlabs-active' : '',
        this.isConnecting ? 'elevenlabs-connecting' : '',
      ];
    },
    iconSize() {
      const sizes = { small: 16, medium: 20, large: 24 };
      return sizes[this.size] || sizes.medium;
    },
    buttonStyle() {
      if (this.isCallActive) {
        return {
          backgroundColor: '#ef4444',
          color: '#ffffff',
        };
      }
      return {};
    },
    tooltipText() {
      if (this.isCallActive) return this.$t('VOICE_AGENT.END_CALL');
      if (this.isConnecting) return this.$t('VOICE_AGENT.CONNECTING');
      return this.$t('VOICE_AGENT.START_CALL');
    },
  },
  mounted() {
    this.loadElevenLabsScript();
  },
  beforeUnmount() {
    this.removeWidget();
  },
  methods: {
    ...mapActions('elevenlabsVoice', ['setActive', 'setConnecting']),

    loadElevenLabsScript() {
      if (this.scriptLoaded || document.querySelector('script[src*="@elevenlabs/convai-widget-embed"]')) {
        this.scriptLoaded = true;
        return;
      }

      const script = document.createElement('script');
      script.src = 'https://unpkg.com/@elevenlabs/convai-widget-embed';
      script.async = true;
      script.type = 'text/javascript';
      script.onload = () => {
        this.scriptLoaded = true;
      };
      document.head.appendChild(script);
    },

    handleClick() {
      if (this.isConnecting) return;

      if (this.isCallActive) {
        this.endCall();
      } else {
        this.startCall();
      }
    },

    async startCall() {
      const config = this.elevenLabsConfig;
      if (!config?.agentId) return;

      this.isConnecting = true;
      this.setConnecting(true);
      this.showVoiceModal = true;

      try {
        // Request microphone permission first
        await navigator.mediaDevices.getUserMedia({ audio: true });

        // Widget will be shown via v-if in template
        this.isConnecting = false;
        this.setConnecting(false);
        this.isCallActive = true;
        this.setActive(true);
      } catch (error) {
        console.error('Failed to start ElevenLabs call:', error);
        this.isConnecting = false;
        this.setConnecting(false);
        this.showVoiceModal = false;

        if (error.name === 'NotAllowedError' || error.name === 'NotFoundError') {
          alert(this.$t('VOICE_AGENT.MICROPHONE_ACCESS'));
        }
      }
    },

    endCall() {
      this.isCallActive = false;
      this.isConnecting = false;
      this.showVoiceModal = false;
      this.setActive(false);
      this.setConnecting(false);
    },

    closeModal() {
      this.endCall();
    },
  },
};
</script>

<template>
  <div class="elevenlabs-container">
    <!-- Voice Call Button -->
    <button
      v-if="shouldShowButton"
      :class="buttonClasses"
      :style="buttonStyle"
      :aria-label="tooltipText"
      :title="tooltipText"
      @click="handleClick"
    >
      <!-- Spinner icon for connecting state -->
      <svg
        v-if="isConnecting"
        :width="iconSize"
        :height="iconSize"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        class="animate-spin text-n-slate-11"
      >
        <circle
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          stroke-width="2"
          stroke-linecap="round"
          stroke-dasharray="31.4 31.4"
          fill="none"
        />
      </svg>

      <!-- End call icon for active state -->
      <svg
        v-else-if="isCallActive"
        :width="iconSize"
        :height="iconSize"
        viewBox="0 0 24 24"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
        class="text-white"
      >
        <path d="M12 2C6.47 2 2 6.47 2 12s4.47 10 10 10 10-4.47 10-10S17.53 2 12 2zm5 13.59L15.59 17 12 13.41 8.41 17 7 15.59 10.59 12 7 8.41 8.41 7 12 10.59 15.59 7 17 8.41 13.41 12 17 15.59z"/>
      </svg>

      <!-- Phone/AI icon for default state -->
      <svg
        v-else
        :width="iconSize"
        :height="iconSize"
        viewBox="0 0 24 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        class="call-icon"
      >
        <!-- Phone receiver -->
        <path
          d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"
          fill="#F87171"
          stroke="#DC2626"
          stroke-width="0.5"
        />
        <!-- Speech bubble -->
        <rect x="10" y="1" width="12" height="9" rx="2" fill="#FDE68A" stroke="#F59E0B" stroke-width="0.5"/>
        <!-- Bubble tail -->
        <path d="M12 10L10 13L14 10H12Z" fill="#FDE68A" stroke="#F59E0B" stroke-width="0.3"/>
        <!-- AI text -->
        <text x="16" y="7" font-size="5" font-weight="bold" fill="#3B82F6" text-anchor="middle" font-family="Arial, sans-serif">AI</text>
      </svg>
    </button>

    <!-- Voice Call Modal Overlay -->
    <Teleport to="body">
      <div v-if="showVoiceModal" class="voice-modal-overlay" @click.self="closeModal">
        <div class="voice-modal">
          <!-- Header -->
          <div class="voice-modal-header">
            <span class="voice-modal-title">
              {{ isConnecting ? $t('VOICE_AGENT.CONNECTING') : elevenLabsConfig?.agentName || 'AI Voice Agent' }}
            </span>
            <button class="voice-modal-close" @click="closeModal" :title="$t('VOICE_AGENT.END_CALL')">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
              </svg>
            </button>
          </div>

          <!-- Content -->
          <div class="voice-modal-content">
            <!-- Status indicator when connecting -->
            <div v-if="isConnecting" class="voice-status">
              <div class="voice-indicator connecting">
                <div class="pulse-ring"></div>
                <div class="pulse-ring delay-1"></div>
                <div class="pulse-ring delay-2"></div>
                <svg class="animate-spin" width="40" height="40" viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" r="10" stroke="#3B82F6" stroke-width="2" stroke-linecap="round" stroke-dasharray="31.4 31.4" fill="none"/>
                </svg>
              </div>
              <p class="voice-status-text">{{ $t('VOICE_AGENT.CONNECTING') }}</p>
              <p class="voice-hint">Please wait...</p>
            </div>

            <!-- ElevenLabs Widget Container -->
            <div class="widget-container" :class="{ 'hidden': isConnecting }">
              <elevenlabs-convai
                v-if="isCallActive && elevenLabsConfig?.agentId"
                :agent-id="elevenLabsConfig.agentId"
                data-chatwoot="true"
              ></elevenlabs-convai>
            </div>

            <p v-if="isCallActive && !isConnecting" class="voice-hint mt-4">
              Click "End Call" below to stop the conversation
            </p>
          </div>

          <!-- Footer with end call button -->
          <div class="voice-modal-footer">
            <button class="end-call-btn" @click="endCall" :disabled="isConnecting">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 9c-1.6 0-3.15.25-4.6.72v3.1c0 .39-.23.74-.56.9-.98.49-1.87 1.12-2.66 1.85-.18.18-.43.28-.7.28-.28 0-.53-.11-.71-.29L.29 13.08a.956.956 0 0 1-.29-.7c0-.28.11-.53.29-.71C3.34 8.78 7.46 7 12 7s8.66 1.78 11.71 4.67c.18.18.29.43.29.71 0 .28-.11.53-.29.71l-2.48 2.48c-.18.18-.43.29-.71.29-.27 0-.52-.1-.7-.28a11.27 11.27 0 0 0-2.67-1.85.996.996 0 0 1-.56-.9v-3.1C15.15 9.25 13.6 9 12 9z"/>
              </svg>
              <span>{{ $t('VOICE_AGENT.END_CALL') }}</span>
            </button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style>
/* Hide any ElevenLabs widgets outside our container */
body > elevenlabs-convai:not([data-chatwoot="true"]) {
  display: none !important;
  visibility: hidden !important;
  pointer-events: none !important;
  width: 0 !important;
  height: 0 !important;
}

/* Make ElevenLabs widget visible inside our container */
.widget-container elevenlabs-convai,
elevenlabs-convai[data-chatwoot="true"] {
  display: block !important;
  position: relative !important;
  width: 100% !important;
  height: auto !important;
  min-height: 280px !important;
  visibility: visible !important;
  pointer-events: auto !important;
  overflow: visible !important;
  inset: unset !important;
  transform: none !important;
  bottom: unset !important;
  right: unset !important;
  left: unset !important;
  top: unset !important;
  z-index: 1 !important;
  margin: 0 auto !important;
}
</style>

<style scoped>
.elevenlabs-container {
  position: relative;
}

.elevenlabs-voice-btn {
  position: relative;
}

.elevenlabs-voice-btn:hover .call-icon {
  transform: scale(1.1);
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.2));
}

.call-icon {
  transition: transform 0.2s ease, filter 0.2s ease;
}

.elevenlabs-active {
  box-shadow: 0 0 0 4px rgba(239, 68, 68, 0.3);
  animation: pulse-ring-active 1.5s cubic-bezier(0.455, 0.03, 0.515, 0.955) infinite;
}

.elevenlabs-connecting {
  opacity: 0.7;
  cursor: wait;
}

/* Modal Styles */
.voice-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  animation: fadeIn 0.2s ease;
}

.voice-modal {
  background: white;
  border-radius: 16px;
  width: 420px;
  max-width: 95vw;
  max-height: 95vh;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease;
  overflow: visible;
}

/* Dark mode support */
.dark .voice-modal {
  background: #1f2937;
}

.voice-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
}

.dark .voice-modal-header {
  background: #374151;
  border-bottom-color: #4b5563;
}

.voice-modal-title {
  font-weight: 600;
  font-size: 16px;
  color: #1f2937;
}

.dark .voice-modal-title {
  color: #f9fafb;
}

.voice-modal-close {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  color: #6b7280;
  transition: all 0.2s;
}

.voice-modal-close:hover {
  background: #fee2e2;
  color: #dc2626;
}

.voice-modal-content {
  padding: 20px;
  text-align: center;
  min-height: 350px;
  height: auto;
  overflow: visible;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.widget-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 300px;
  height: 350px;
  overflow: visible;
  position: relative;
  background: transparent;
}

.widget-container :deep(elevenlabs-convai) {
  width: 100% !important;
  max-width: 100% !important;
  position: relative !important;
  bottom: auto !important;
  right: auto !important;
}

.mt-4 {
  margin-top: 16px;
}

.hidden {
  display: none !important;
}

.voice-status {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
}

.voice-indicator {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #eff6ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 16px;
}

.voice-indicator.connecting {
  background: #fef3c7;
}

.pulse-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 2px solid #3b82f6;
  animation: pulse-expand 2s ease-out infinite;
  opacity: 0;
}

.pulse-ring.delay-1 {
  animation-delay: 0.5s;
}

.pulse-ring.delay-2 {
  animation-delay: 1s;
}

.voice-status-text {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.dark .voice-status-text {
  color: #f9fafb;
}

.voice-hint {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.voice-modal-footer {
  padding: 20px;
  background: #f9fafb;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: center;
}

.dark .voice-modal-footer {
  background: #374151;
  border-top-color: #4b5563;
}

.end-call-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: #ef4444;
  color: white;
  border: none;
  padding: 12px 32px;
  border-radius: 50px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.end-call-btn:hover:not(:disabled) {
  background: #dc2626;
  transform: scale(1.05);
}

.end-call-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Animations */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes pulse-ring-active {
  0% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.4); }
  70% { box-shadow: 0 0 0 10px rgba(239, 68, 68, 0); }
  100% { box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
}

@keyframes pulse-expand {
  0% {
    transform: scale(1);
    opacity: 0.6;
  }
  100% {
    transform: scale(1.8);
    opacity: 0;
  }
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>
