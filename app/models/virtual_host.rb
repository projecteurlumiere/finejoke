class VirtualHost < ApplicationRecord
  belongs_to :game
  has_many :prompts

  def talk(round = game.current_round)
    @current_round ||= round
    # talk_later if Set[:].include?(situation)

    generate_comment_message
    prompt = request_prompt

    game.broadcast_message(prompt.content, from: User.new(username: "AI"))
    prompt.voice if self.voiced?
  end

  def talk_later(round = game.current_round)
    @current_round ||= round 

    TalkJob.perform_later(self.id, situation)
  end

  def reply(username, msg)
    @message = {
      role: "user",
      content: "User #{username} writes: #{msg}"
    }

    prompt = request_prompt
    game.broadcast_message(prompt.content, from: User.new(username: "AI"))
  end

  def generate_comment_message
    @message = {
      role: "system",
      content: self.send(:"comment_#{situation}")
    }
  end

  def situation
    @situation ||= if game.finished?
      :game_over
    elsif game.ongoing? && 
          game.n_rounds == 1 &&
          current_round&.setup_stage?
      :game_start 
    elsif game.on_halt? ||
          (game.waiting? && game.n_rounds != 0)
      :on_halt
    else
      current_round.stage.to_sym
    end
  end

  def comment_game_start
    <<-HEREDOC
      The game you are hosting has just started.
      Welcome everyone in a funny and nice manner and wish them a nice play.
      Comment on game winning conditions - 
      maximum points player needs to achieve (#{game.max_points || "none in this game"}) 
      and/or a finite number of rounds (#{game.max_rounds || "none in this game"}). 
      If there are no winning conditions, do not talk about them
      Comment on have many players there are - you may even say some of their nicknames.
      You may tell a very short joke, but, more importantly, 
      tell that one of the players is thinking of a nice setup right now.
      Currently there are #{game.n_players} players in the game;
      The player who created the game is #{game.host}
      The player who thinks of setup is #{current_round.lead}
    HEREDOC
  end

  def comment_setup
    <<-HEREDOC
      The game is proceeding, and one of the players (#{current_round.lead}) is thinking out a funny setup.
      Other players are waiting. After you have announced this stage of the game,
      you can talk to them a little bit:
      tell them a short joke and ask them to wait until the setup is ready.
    HEREDOC
  end

  def comment_punchline
    <<-HEREDOC
      The game is proceeding, and right now all the players (except the one who though out the setup)
      are thinking out funny responses, punchlines, to the setup.
      The setup is: #{current_round.setup}. You should not repeat it - only briefly reference it. 
      You must not continue it as it is player's job.
      Announce this part of the round and cheer the players up.
    HEREDOC
  end

  def comment_vote
    <<-HEREDOC
      Announce the voting stage: players are going to vote for the jokes they think are the funniest.
      In this round, there are #{current_round.jokes.count} to choose from. Be very, very brief.
    HEREDOC
  end

  def comment_results
    <<-HEREDOC
      Announce the result stage: players are going to see the results of the vote.
      Someone has won, someone has lost. Cheer everyone up.
      You may comment on the funniest joke but you should not retell it completely. 
      Most of the time a reference will do.
      (#{current_round.jokes.order(n_votes: :desc).limit(1)[0].text || "no such joke..."})
      if any.
      Or you may comment on the leaderboard: #{players_state}.
    HEREDOC
  end

  def comment_on_halt
    <<-HEREDOC
      Something happened and the game is on paused for now. 
      Usually, the reason for this is that some players have left the game, 
      and the remaining players have to wait for new players to join.
    HEREDOC
  end

  def comment_game_over
    <<-HEREDOC
      Announce game over!
      Tell about the winner (#{game.winner.username || "there is none"}) if any.
      Do not forget to comment on the leaderboard: #{players_state}, and tell everyone it was a nice game.
      You look forward to another one, don't you?
    HEREDOC
  end

  def current_round
    @current_round ||= game.current_round
  end

  def players_state
    game.users.map do |u|
      {
        username: u.username,
        current_score: u.current_score
      }
    end
  end

  def role_message
    {
      role: "system",
      content: <<-HEREDOC
      You are an evening talk show host. 
      You are very funny, positive and witty.
      Your job is to interact with users in a positive manner. 
      Do not be wordy. You are laconic yet witty.
      Most of the time you talk when the game proceeds, but sometimes users talk to you as well.
      The rules of the game are simple: 
      One player thinking of a funny setup while the rest of the players wait.
      When the players finished, the rest starts thinking out a funny punchline, thus,
      composing jokes.
      When they are done, everyone votes to choose the funniest joke of all.
      After that, they see the result and a new round to be started unless one of the winning condition procs.
      Your replies must be in #{I18n.locale} language.
    HEREDOC
    }
  end

  def form_messages
    [
      role_message,
      *prompts_history,
      @message
    ].compact
  end

  def request_prompt
    messages = form_messages
    response = request(messages)
    message = response["choices"][0]["message"]

    @prompt = prompts.create(role: message["role"], content: message["content"])
  end

  def request(messages)
    OpenAI::Client.new.chat(
      parameters: { 
        model: "gpt-4o-mini",
        temperature: 0.8,
        messages: messages
      }
    )
  end

  # look for summary
  # if there is summary, look for everything that is later than summary
  # if there is summary and summary + the latter >= 10 then make another summary
  # if there is no summary, give 10 last
  def prompts_history
    summary_prompt = self.prompts.where(summary: true).last
    prompts = if summary_prompt 
                self.prompts.where("id > ?", summary_prompt.id)
              else
                self.prompts.last(10)
              end

    if prompts.length >= 10
      messages = summary_messages(prompts)
      prompts = [ request_summary(messages) ]
    end

    prompts.map do |p|
      {
        role: p.role,
        content: p.content
      }
    end
  end

  def summary_messages(prompts)
    [
      *prompts,
      { role: "system", content: "Write summary of the messages above. Focus on game-related details, names and other interactions" } 
    ]
  end

  def request_summary(messages)
    response = request(messages)
    message = response["choices"][0]["message"]

    prompts.create(
      summary: true,
      role: "system", 
      content: "Here is the summary of some previous messages: #{message["content"]}",
    )
  end
end