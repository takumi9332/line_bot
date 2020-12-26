class LinebotController < ApplicationController
  require 'line/bot'
  protect_from_forgery except: :callback

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      if event.message['text'].include?("グー") || event.message['text'].include?("ぐー")
        response = "パー"
      elsif event.message['text'].include?("チョキ") || event.message['text'].include?("ちょき")
        response = "グー"
      elsif event.message['text'].include?("パー") || event.message['text'].include?("ぱー")
        response = "チョキ"
      else
        response = "グーチョキパー"
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end
end
