# Unused for now
# Enable active storage before using this
module Prompts
  module Voicable
    extend ActiveSupport::Concern

    included do
      has_one_attached :audio

      def voice
        generate_audio
        broadcast_audio
      end

      def generate_audio
        response = OpenAI::Client.new.audio.speech(
          parameters: {
            model: "tts-1",
            input: content,
            voice: "onyx"
          }
        )

        audio.attach(
          io: StringIO.new(response, 'rb'),
          filename: "prompt_#{id}.mp3"
        )
      end

      def broadcast_audio
        game.broadcast_render_to(game.stream_name,
          partial: "games/game_virtual_host_voice",
          formats: [:turbo_stream],
          locals: {
            prompt: self
          })
      end
    end
  end
end

