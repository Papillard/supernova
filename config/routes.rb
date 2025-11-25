Rails.application.routes.draw do

  # Defines the root path route ("/")
  root "pages#home"

  # Devise routes with custom controllers
  devise_for :users, controllers: {
    sessions: 'sessions',
    passwords: 'devise/passwords'
  }

  # Parent signup
  devise_scope :user do
    get 'parents/sign_up', to: 'parents/registrations#new', as: :new_parent_registration
    post 'parents/sign_up', to: 'parents/registrations#create', as: :parent_registration
  end

  # Teacher signup
  devise_scope :user do
    get 'teachers/sign_up', to: 'teachers/registrations#new', as: :new_teacher_registration
    post 'teachers/sign_up', to: 'teachers/registrations#create', as: :teacher_registration
  end

  # Pages
  get "pages/home"

  # Teachers listing (placeholder)
  get "teachers", to: "teachers#index", as: :teachers

  # Teacher dashboard (placeholder)
  get "dashboard/teacher", to: "dashboard/teachers#show", as: :dashboard_teacher

end
