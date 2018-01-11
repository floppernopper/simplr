class BotTask < ActiveRecord::Base
  belongs_to :bot
  
  before_create :gen_unique_token
  validate :named?, on: :create
  
  def self.task_types
    { reset_table: 'Reset Tables - (╯°□°)╯︵ ┻━┻  ... ┬─┬﻿ ノ( ゜-゜ノ)',
      grow: 'Grow - Enable bot to reproduce with other bots',
      learn: 'Learn - Collect or gather data from users' }
  end
  
  private
    def named?
      unless self.name.present?
        errors.add :bot_task, "must be named."
      end
    end
    
    def gen_unique_token
      self.unique_token = SecureRandom.urlsafe_base64
    end
end
