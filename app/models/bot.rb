class Bot < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  belongs_to :bot

  has_many :bots, dependent: :destroy
  has_many :bot_tasks, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  before_create :gen_uniqueness

  mount_uploader :image, ImageUploader

  def self.manifest_bots tasks=[], items={}
    for task in tasks
      # initializes some bots standing idle for task
      idle_bots = Bot.idle_for_task(task)
      if idle_bots.present?
        idle_bots.sample(rand(1..idle_bots.size)).each do |bot|
          _task = bot.bot_tasks.find_by_name(task.to_s)
          _task.update page: items[:page].to_s if _task
        end
      end
      # if any bots are performing task on given page
      if BotTask.where(name: task, page: items[:page].to_s).present?
        # gets array of bots performing task on page
        bot_pool = Bot.for_task_on_page task, items[:page]
        case task
        when :reset_table
          bot = bot_pool.sample
          comments = items[:comments]
          if comments.present? and comments.last.body.include? "(╯°□°)╯︵ ┻━┻"
            comment = comments.new bot_id: bot.id, body: "┬─┬﻿ ノ( ゜-゜ノ)"
            comment.save
          end
        when :grow
          if bot_pool.size > 1
            # bot joins with another growing bot if present on same page and compatible
            samples = bot_pool.sample 2; bot = samples[0]; other_bot = samples[1]
            compatibility = bot.determine_compatibility other_bot
            if compatibility[:compatible]
              parent_bot = Bot.find_by_id compatibility[:parent_id]
              # potential to spawn more than one child bot
              rand(1..compatibility[:difference]).times do
                # creates child bot with tokens pointing back to both parents
                child_bot = parent_bot.bots.new parent_tokens: compatibility[:parent_tokens]
                if child_bot.save
                  # starts child bot off with same task
                  child_bot.bot_tasks.create name: "grow"
                  # doesn't get initialized to page until next refresh
                end
              end
            end
          end
        when :learn
          bot = bot_pool.sample
          # bot to start saving data within task attributes or some other model
        end
      end
    end
  end

  # returns pool of bots for task on page
  def self.for_task_on_page task_name, page
    on_page = []
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name
      if task and task.page.eql? page.to_s
        on_page << bot
      end
    end
    return on_page
  end

  def self.idle_for_task task_name
    idle = []
    for bot in Bot.all
      task = bot.bot_tasks.find_by_name task_name
      if task and not task.page.present?
        idle << bot
      end
    end
    return idle
  end

  # to determine parent compatibility
  def determine_compatibility bot
    compatibility = { compatible: false }
    if bot
      # gets number occurance counts (gender) for both bots
      self_count = self.gender; other_count = bot.gender
      # puts both in array for number occurance comparison
      both_counts = [self_count, other_count].sort
      # sets the difference based on number occurance in tokens
      difference = (both_counts[0]...both_counts[1]).size
      # checks the difference and relation for compatibility
      if difference >= 2 and not self.related? bot
        compatibility[:compatible] = true
        # difference between will determine how many potential children
        compatibility[:difference] = difference
        # sets parent_tokens here for easier access above
        compatibility[:parent_tokens] = [self.unique_token, bot.unique_token].to_s
        # the parent with the largest occurance of numbers
        compatibility[:parent_id] = if self_count > other_count
          self.id
        else
          bot.id
        end
      end
    end
    return compatibility
  end

  def old?
    # old if older than 3/4's of population
    younger = Bot.where("created_at > '#{self.created_at}'").size
    if younger.to_f / Bot.all.size.to_f > 0.75
      true
    else
      false
    end
  end

  def related? other_bot
    related = false
    [:children, :parents, :siblings].each do |sym|
      if self.send(sym).include? other_bot
        related = true
      end
    end
    return related
  end

  def children
    _children = []
    for child in Bot.where.not(parent_tokens: nil)
      _children << child if eval(child.parent_tokens).include? self.unique_token
    end
    return _children
  end

  def parents
    _parents = []
    for bot in Bot.all
      _parents << bot if self.parent_tokens.present? and eval(self.parent_tokens).include? bot.unique_token
    end
    return _parents
  end

  def siblings
    _siblings = []
    for parent in self.parents
      for child in parent.children
        unless _siblings.include? child or self.eql? child
          _siblings << child
        end
      end
    end
    return _siblings
  end

  def mates
    _mates = []
    for child in self.children
      for parent in child.parents
        unless _mates.include? parent or self.eql? parent
          _mates << parent
        end
      end
    end
    return _mates
  end

  def gender
    self.unique_token.scan(/\d+/).count
  end

  private

  def gen_uniqueness
    gen_unique_token
    gen_unique_bot_name
  end

  # sets a generic bot name for bot unless named by user
  def gen_unique_bot_name
    unless self.name.present?
      name = $name_generator.next_name
      self.name = "#{name}_" + self.unique_token
    end
  end

  def gen_unique_token
    self.unique_token = SecureRandom.urlsafe_base64
  end
end
