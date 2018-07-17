class TemplatesController < ApplicationController
  before_action :set_templating, only: [:semantic_ui, :uikit, :purecss, :sample_blog]
  before_action :set_on_point, only: [:calendar, :on_point, :pricing]
  
  layout :resolve_layout

  def lil_c
    @lil_c = true
  end

  def index
    @forrest_web_co = true
  end

  def semantic_ui
    @semantic_ui = @forrest_web_co = true
  end

  private
  
  def resolve_layout
    case action_name.to_sym
    when :on_point, :calendar
      "on_point"
    else
      "application"
    end
  end
  
  def set_on_point
    @on_point = true
  end

  def set_templating
    @templating = true
  end
end
