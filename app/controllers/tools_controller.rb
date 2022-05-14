class ToolsController < ApplicationController
  def create
    CreateToolService.new(params).create
  end

  def update
  end
end
