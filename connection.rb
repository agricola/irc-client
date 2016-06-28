class Connection

  attr_writer :channel

  #connect to IRC server
  def initialize( display, hostname, port, username, realname, channel )

    @hostname = hostname
    @port = port
    @username = username
    @channel = channel
    @realname = realname
    @display = display
    @channels = []
    #@connection_display = connection_display

    @display.connection = self

    connectToIRC
  end

  # Send any text to the server, if no command is given assumes PRIVMSG
  def sendTextToServer(text)

    if text[0] == "/"
      text[0] = ""
      string = "#{text}\r\n"
      #exit if string == "quit\r\n"
    else
      string = "PRIVMSG #{@channel} :#{text}\r\n"
      @display.sendToChat("#{@channel} #{@username} #{text}\n")
    end
    @sock.send(string, 0)
  end
  
  def connectToChannel(channel_name)
    #puts channel_name
    @display.channel_name_field.setText(channel_name)
    @sock.send("JOIN #{channel_name}\r\n", 0)
  end

  private

  # Open the IRC server's socket and connects to it
  def connectToIRC
    @sock = TCPSocket.new(@hostname, @port)
    @sock.send("NICK #{@username}\r\n", 0)
    @sock.send("USER #{@username} 0 * : #{@realname}\r\n", 0)
    #connectToChannel(@channel)

    while line = @sock.gets
      processed_line = IRCLine.new(line.chop)

      if processed_line.ping
        @sock.send("PONG #{processed_line.message}\r\n", 0)
      else
        @display.sendToChat(processed_line.output)
      end
    end

    @sock.close
  end
end

