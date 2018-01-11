class MessagesController < ApplicationController
  before_action :set_message, only: [:show]
  before_action :invite_only
  
  def currently_typing
    @folder = Message.folders.find_by_id params[:folder_id]
    @user = User.find_by_id params[:user_id]
    member = @folder.members.find_by_user_id @user.id
    member.update last_typing_at: DateTime.now
  end

  # create folder between users if none exists
  def create_message_folder
    @folder = Connection.new message_folder: true
    # initializes users list with sending user
    @users = [current_user]
    # if with just one other user
    if params[:user_id]
      user = User.find_by_id params[:user_id]
      @users << user if user
    # with multiple users
    elsif params[:users]
      # gets each user by name from users param
      @users = extract_users params[:users], @users
    end
    # saves new folder or gets old one if present
    if Connection.folder_with @users
      @folder = Connection.folder_with @users
    elsif @folder.save
      for user in @users
        @folder.connections.create user_id: user.id
      end
    end
    # redirects to folder page or back if errors occurred
    if @folder and @folder.id
      # creates initial message if present
      if params[:body].present?
        @folder.messages.create body: params[:body],
          user_id: current_user.id, sender_token: current_user.unique_token
      end
      redirect_to show_message_folder_path @folder
    else
      redirect_to :back
    end
  end

  def show_message_folder
    @folder = Connection.find_by_id params[:folder_id]
    @new_message = Message.new
    if @folder
      @folder_shown = true
      @messages = @folder.messages.last 10
      set_last_message_seen
      set_last_im
      for message in @folder.messages
        seent message
      end
    else
      redirect_to '/404'
    end
  end

  def message_folders
    @folders = current_user.message_folders
    # destroys any empty folders that are older than the specified time
    @folders.each { |folder| folder.destroy if folder.messages.empty? and folder.created_at < 1.hour.ago }
    # sorts folders chronologically by folder creation or last message creation if messages are present
    @folders.sort_by! do |folder|
      (folder.messages.empty? ? folder.created_at : folder.messages.last.created_at)
    end
    @folders.reverse!
  end

  def add_image
  end

  def create
    @new_message = Message.new # for ajax, new form
    @group = Group.find_by_id params[:group_id]
    @folder = Connection.find_by_id params[:folder_id]
    @message = Message.new(message_params)
    @message.user_id = current_user.id
    @message.group_id = params[:group_id]
    @message.connection_id = params[:folder_id]
    # to be used as the key for encrypting the message
    @message.sender_token = current_user.unique_token
    if @message.save and @folder
      Tag.extract @message
      seent @message
        # notifications turned off for now
#      for member in @folder.members
#        next if member.user.eql? current_user
#        Note.notify :message_received, @folder, member.user, current_user
#      end
    end
  end

  def instant_messages
    @group = Group.find_by_id(params[:group_id])
    @folder = Connection.find_by_id(params[:folder_id])
    @instant_messages = []
    @messages = if @group
      @group.messages
    elsif @folder
      @folder.messages
    end
    for message in @messages
      if check_last_im(message)
        @instant_messages << message
        seent message
      end
    end
    set_last_im
    unless @instant_messages.empty?
      @instant_messages = @messages.last(10)
    end
    
    actively_typing_members = @folder.members.where.not last_typing_at: nil, user_id: current_user.id
    
    if actively_typing_members.present?
      member = actively_typing_members.sort_by { |m| m.last_typing_at }.last
      if member.last_typing_at >= 30.second.ago
        @actively_typing_member = member
      end
    end
    
  end

  def index
    msg_limit = 3 # how many to display
    @new_message = Message.new
    @group = Group.find_by_id(params[:group_id])
    if @group
      @messages ||= @group.messages.last msg_limit
      set_last_im
    end
  end

  def show
  end

  private
  
  def extract_users user_names="", users=[]
    # splits user names by comma and space (", ")
    # needs to also account for any extra white space
    user_names.split(", ").each do |name|
      user = User.find_by_name name
      # adds user to users unless name not found or is current user
      unless user.nil? or user.eql? current_user
        users << user
      end
    end
    return users
  end

  # for displaying number of unseen folder messages
  def set_last_message_seen
    unless @folder.messages.empty?
      @connection = @folder.connections.find_by_user_id current_user.id
      unless @folder.messages.size.eql? @connection.total_messages_seen
        @connection.update total_messages_seen: @folder.messages.size
      end
    end
  end

  def check_last_im message
    # eval to inflate hash from string
    in_sequence = false; last_im = eval(cookies[:last_im].to_s)
    if last_im.class.eql? Hash and message.id > last_im[:message_id].to_i
      if @group and last_im[:group_id].eql? @group.id
        in_sequence = true # meaning not the last message
      elsif @folder and last_im[:folder_id].eql? @folder.id
        in_sequence = true # meaning not the last message
      end
    end
    return in_sequence
  end

  # keeps track of last message loaded
  def set_last_im
    message_id = if @instant_messages.present?
      @instant_messages.last.id
    # last group message on page load, before ajax call
    elsif @group and @group.messages.present?
      @group.messages.last.id
    # last folder message on page load, before ajax
    elsif @folder and @folder.messages.present?
      @folder.messages.last.id
    else
      nil
    end
    last_im = { message_id: message_id }
    last_im[:group_id] = @group.id if @group
    last_im[:folder_id] = @folder.id if @folder
    cookies[:last_im] = last_im.to_s if last_im[:message_id]
  end

  def invite_only
    unless invited?
      redirect_to invite_only_path
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = Message.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.require(:message).permit(:user_id, :group_id, :body, :image)
  end
end
