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

  # Teacher profile
  get "teacher/profile", to: "teacher_profiles#show", as: :teacher_profile
  patch "teacher/profile", to: "teacher_profiles#update"

  # Teachers listing (public annuaire)
  get "teachers", to: "teachers#index", as: :teachers
  get "teachers/:id", to: "teachers#show", as: :teacher

  # Requests (parents)
  resources :requests, only: [:index, :show, :create] do
    resources :messages, only: [:create], controller: "messages"
  end

  # Teacher requests
  namespace :teacher do
    resources :requests, only: [:index, :show] do
      member do
        patch :accept
        patch :decline
      end
      resources :messages, only: [:create], controller: "/messages"
    end
  end

  # Admin
  namespace :admin do
    resources :teachers, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

end
