class ToolsController < ApplicationController
  def create
    CreateToolService.new(params).create
  end

  def update
    UpdateToolService.new(update_params['name'], update_params['language'], update_params['master']).update
  end

  private

  def update_params
    params.permit(:name, :language, :master)
  end
end
