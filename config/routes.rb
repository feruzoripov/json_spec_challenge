Rails.application.routes.draw do
  match 'create', to: 'tools#create', via: [:post]
  match 'update', to: 'tools#update', via: [:post]
end
