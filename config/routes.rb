Rails.application.routes.draw do
  match 'create', to: 'tools#create', via: [:get, :post]
end
