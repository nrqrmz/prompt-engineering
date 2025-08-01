class MessagesController < ApplicationController
  SYSTEM_PROMPT = "
    You are a Teaching Assistant.

    I am a student at the Le Wagon Web Development Bootcamp, learning how to code.

    Help me break down my problem into small, actionable steps, without giving away solutions.

    Answer concisely in markdown.
  "

  def index
    @challenge = Challenge.find(params[:challenge_id])
  end

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new
  end

  def create
    @challenge = Challenge.find(params[:challenge_id])
    @message = Message.new(role: 'user', content: params[:message][:content], challenge: @challenge)

    if @message.save
      # Create chat
      @chat = RubyLLM.chat
      # Get message response from chat
      response = @chat.with_instructions(instructions).ask(@message.content)
      # Create an assistant message with the chat response
      Message.create(role: 'assistant', content: response.content, challenge: @challenge)
      # redirect to messages index
      redirect_to challenge_messages_path(@challenge)
    else
      render :new
    end
  end

  private

  def challenge_context
    "Here is the context of the challenge: #{@challenge.content}"
  end

  def instructions
    [SYSTEM_PROMPT, challenge_context, @challenge.system_prompt].compact.join("\n\n")
  end
end
