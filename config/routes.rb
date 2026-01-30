Rails.application.routes.draw do
  # Redirect prof-connect.fr to www.prof-connect.fr in production
  if Rails.env.production?
    constraints(host: /\Aprof-connect\.fr\z/i) do
      match "*path", to: redirect { |params, req| "https://www.prof-connect.fr#{req.fullpath}" }, via: :all
    end
  end

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
  get "conditions-generales", to: "pages#conditions_generales", as: :conditions_generales
  get "politique-de-confidentialite", to: "pages#politique_de_confidentialite", as: :politique_de_confidentialite
  get "mentions-legales", to: "pages#mentions_legales", as: :mentions_legales

  # Teacher profile
  get "teacher/profile", to: "teacher_profiles#show", as: :teacher_profile
  patch "teacher/profile", to: "teacher_profiles#update"

  # Teacher verification documents
  resources :teacher_verification_documents, only: [:create, :destroy], path: "teacher/verification_documents"

  # Parent profile
  get "parent/profile", to: "parent_profiles#show", as: :parent_profile
  patch "parent/profile", to: "parent_profiles#update"

  # Account (email and password management)
  get "account", to: "accounts#edit", as: :account
  patch "account", to: "accounts#update"

  # Students (nested under parent profile)
  resources :students, only: [:create, :destroy]

  # Profile completion page
  get "parent/profile/complete", to: "parent_profiles#complete", as: :parent_profile_complete

  # Teachers listing (public annuaire)
  get "teachers", to: "teachers#index", as: :teachers
  get "teachers/:id", to: "teachers#show", as: :teacher

  # Requests (parents)
  resources :requests, only: [:index, :show, :create] do
    member do
      patch :archive
    end
    resources :messages, only: [:create], controller: "messages"
  end

  # Teacher requests
  namespace :teacher do
    resources :requests, only: [:index, :show] do
      member do
        patch :accept
        patch :decline
        patch :archive
      end
      resources :messages, only: [:create], controller: "/messages"
    end
  end

  # Admin
  namespace :admin do
    resources :teachers, only: [:index, :show, :edit, :update] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

end
