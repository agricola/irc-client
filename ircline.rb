class IRCLine

  # Turn messages from servers to clean messages
  attr_reader :name, :command, :message, :channel, :output, :topic, :ping  #might not need all these readable

  def initialize(text)
    @string = text
    @name = nil
    @command = nil
    @message = nil
    @channel = nil
    @output = ""
    @ping = false


    processLinesFromServer(@string)

    outputBasedOnCommand

    #puts "NAME: #{@name}", "COMMAND: #{@command}", "MESSAGE: #{@message}", "CHANNEL: #{@channel}"
  end

  private

  def processLinesFromServer(string)
    prefix = nil
    command = nil
    command_param = nil
    param = ""

    parsed = string.split(":")

    if parsed[0].strip == "PING"
      @ping = true 
      @message = ":#{parsed[1]}"
      return
    end

    first_half = parsed[1].split
    prefix = first_half[0]
    command = first_half[1]
    command_param = first_half
    command_param.delete_at(0)
    command_param.delete_at(0)

    parsed.delete_at(0)
    parsed.delete_at(0)
    param = parsed.join(":")

    name = nil
    user = nil
    host = nil

    prefix_parse = prefix.split("!")
    name = prefix_parse[0]
    if prefix_parse.length > 1
      userhost_parse = prefix_parse[1].split("@")
      user = userhost_parse[0]
      host = userhost_parse[1]
    end

    @name = name
    @command = command
    @message = param
    @channel = command_param[0] if (command_param.length > 0) && (command_param[0].length > 0) && (command_param[0][0] == "#")
  end

  def outputBasedOnCommand
    case @command
    when "TOPIC"
      @output = "#{@channel} #{@name} *CHANGES TOPIC TO: #{message}\n"
    when "JOIN"
      @output = "#{@channel} #{@name} *HAS JOINED: #{message}\n"
    when "MODE"
      @output = ""
    when "PART"
      @output = "#{@channel} #{@name} *HAS LEFT: #{message}\n"
    else
      @output = "#{@channel} #{@name} #{message}\n"
    end
  end
end