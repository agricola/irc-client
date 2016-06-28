# Very basic IRC client with a GUI
include Java
require 'socket'
require_relative 'ircline'
require_relative 'connection'

import java.awt.Dimension
import java.awt.Color
import javax.swing.SwingConstants
import javax.swing.JFrame
import javax.swing.JTextArea
import javax.swing.JTextField
import javax.swing.BorderFactory
import javax.swing.GroupLayout
import javax.swing.JList
import javax.swing.JComboBox
import javax.swing.JScrollPane
import java.awt.event.KeyEvent
import javax.swing.text.DefaultCaret
#import javax.swing.ImageIcon
import javax.swing.DefaultComboBoxModel
import javax.swing.JLabel
import javax.swing.JButton
import javax.swing.JDialog

class MainWindow < JFrame

  # Display the GUI
  attr_writer :connection, :hostname, :port, :username, :channel, :realname
  attr_accessor :channel_name_field

  def initialize()
    super("agrIRC")

    @chat_text = ""
    @connection = nil
    @hostname = nil
    @port = nil
    @username = nil
    @channel = nil
    @realname = nil

    createUI

    connect_window = ConnectWindow.new(self)
    connect(self, @hostname, @port, @username, @realname, @channel)
  end

  # Create all the GUI items and format them
  def createUI
    layout = GroupLayout.new(getContentPane)
    getContentPane.setLayout(layout)
    layout.setAutoCreateGaps(true)
    layout.setAutoCreateContainerGaps(true)
    setPreferredSize(Dimension.new(500, 500))

    @chat_area = JTextArea.new
    @chat_area.setEditable(false)
    @chat_area.setBorder(BorderFactory.createLineBorder(Color.gray))
    @chat_area.setLineWrap(true)
    caret = @chat_area.getCaret
    caret.setUpdatePolicy(DefaultCaret::ALWAYS_UPDATE)

    areaScrollPane = JScrollPane.new
    areaScrollPane.getViewport.add(@chat_area)
    areaScrollPane.setVerticalScrollBarPolicy(JScrollPane::VERTICAL_SCROLLBAR_ALWAYS)

    @input_field = JTextField.new
    @input_field.addKeyListener do |e|
      sendText if e.keyCode == 10
    end

    @channel_name_field = JTextField.new
    @channel_name_field.setMaximumSize(Dimension.new(100, 30))
    @channel_name_field.setText("Put channel here")
    @channel_name_field.setToolTipText("Put a channel here to chat in that channel. Press enter to join it.")
    @channel_name_field.addKeyListener do |e|
      @connection.connectToChannel(@channel_name_field.getText) if e.keyCode == 10
    end

    s = []  #sequential groups
    p = []  #parallel groups

    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    p << layout.createParallelGroup
    p << layout.createParallelGroup
    p[0].addComponent(areaScrollPane)
    s[0].addComponent(@input_field)
    s[0].addComponent(@channel_name_field)
    p[0].addGroup(s[0])
    s[1].addGroup(p[0])
    layout.setHorizontalGroup(s[1])

    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    p << layout.createParallelGroup
    p << layout.createParallelGroup
    p << layout.createParallelGroup
    p[2].addComponent(areaScrollPane)
    p[3].addComponent(@input_field)
    p[3].addComponent(@channel_name_field)
    s[2].addGroup(p[2])
    s[2].addGroup(p[3])
    layout.setVerticalGroup(s[2])

    layout.linkSize(SwingConstants::VERTICAL, @input_field, @channel_name_field)

    pack
    setDefaultCloseOperation(JFrame::EXIT_ON_CLOSE)
    setLocationRelativeTo(nil)
    setVisible(true)
  end

  # Send text from the input field to the server
  def sendText
    text = @input_field.getText
    if @connection != nil
      @connection.channel =  @channel_name_field.getText
      @connection.sendTextToServer(text) if text != ""
    else
      sendToChat("*NOT CONNECTED*")
    end
    @input_field.setText("")
  end

  # Send text to the chat area
  def sendToChat(text)
    return unless text.is_a?(String)
    @chat_text += text
    @chat_area.setText(@chat_text)
  end

  def changeChannelText(text)
    @channel_name_field.setText(text) if text.is_a?(String)
  end

  def connect(main_window, hostname, port, username, realname, channel)
    Connection.new( main_window, hostname, port, username, realname, channel)
  end

end

class ConnectWindow < JDialog

  # Display the connection dialog

  def initialize(frame)
    super(frame, "Connect", true)
    @frame = frame
    createUI
  end

  private

  def createUI
    # Create all the GUI items and format them
    layout = GroupLayout.new(getContentPane)
    getContentPane.setLayout(layout)
    layout.setAutoCreateGaps(true)
    layout.setAutoCreateContainerGaps(true)
    setPreferredSize(Dimension.new(225, 200))

    #img = ImageIcon.new("/bin/icon_image.png")
    #setIconImage(img.getImage)

    hostname_label = JLabel.new("Hostname:")
    port_label = JLabel.new("Port:")
    username_label = JLabel.new("Username:")
    realname_label = JLabel.new("Real name:")
    #channel_label = JLabel.new("Channel:")

    hostname_text = JTextField.new('irc.freenode.net')
    hostname_text.setPreferredSize(Dimension.new(100, 20))
    port_text = JTextField.new('6667')
    username_text = JTextField.new('ag_test92')
    realname_text = JTextField.new('Testman')
    #channel_text = JTextField.new('#irctest92')

    connect_button = JButton.new("Connect")

    connect_button.add_action_listener do |e|
       @frame.hostname = hostname_text.getText
       @frame.port = port_text.getText
       @frame.username = username_text.getText
       @frame.realname = realname_text.getText
       #@frame.channel = channel_text.getText
      self.dispose
    end

    s = []  #sequential groups
    p = []  #parallel groups

    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    p << layout.createParallelGroup
    p << layout.createParallelGroup
    p << layout.createParallelGroup(GroupLayout::Alignment::CENTER)

    p[0].addComponent(hostname_label)
    p[0].addComponent(port_label)
    p[0].addComponent(username_label)
    p[0].addComponent(realname_label)
    #p[0].addComponent(channel_label)
    p[1].addComponent(hostname_text)
    p[1].addComponent(port_text)
    p[1].addComponent(username_text)
    p[1].addComponent(realname_text)
    #p[1].addComponent(channel_text)
    s[0].addGroup(p[0])
    s[0].addGroup(p[1])
    p[2].addGroup(s[0])
    p[2].addComponent(connect_button)
    layout.setHorizontalGroup(p[2])

    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    s << layout.createSequentialGroup
    p << layout.createParallelGroup

    s[1].addComponent(hostname_label)
    s[1].addComponent(port_label)
    s[1].addComponent(username_label)
    s[1].addComponent(realname_label)
    #s[1].addComponent(channel_label)
    s[2].addComponent(hostname_text)
    s[2].addComponent(port_text)
    s[2].addComponent(username_text)
    s[2].addComponent(realname_text)
    #s[2].addComponent(channel_text)
    p[3].addGroup(s[1])
    p[3].addGroup(s[2])
    s[3].addGroup(p[3])
    s[3].addComponent(connect_button)
    layout.setVerticalGroup(s[3])

    layout.linkSize(SwingConstants::HORIZONTAL, hostname_text, port_text, username_text, realname_text)
    layout.linkSize(SwingConstants::VERTICAL, hostname_text, port_text, username_text, realname_text, hostname_label, port_label, username_label, realname_label)

    pack
    setDefaultCloseOperation(JFrame::DISPOSE_ON_CLOSE)
    setLocationRelativeTo(nil)
    setVisible(true)
  end

end

if __FILE__ == $0
  main_window = MainWindow.new  
end