class TemplatesController < ApplicationController
  before_action :set_templating, only: [:semantic_ui, :uikit, :purecss, :sample_blog, :on_point]

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

  def set_templating
    @templating = true
  end
end
