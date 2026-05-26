Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentifizierung (Rails-8-Stil, ohne Devise). Login/Logout liegt im
  # UserSessionsController, weil SessionsController bereits die Kurs-Termine verwaltet.
  resource  :registration, only: %i[new create]
  resource  :session, only: %i[new create destroy], controller: "user_sessions"

  # Öffentlicher Marketplace (Lernende). Getrennt von der Admin-Verwaltung (CoursesController).
  get "katalog", to: "catalog#index", as: :catalog
  get "kurse/:id", to: "catalog#show", as: :catalog_course

  resources :courses do
    resources :sessions,     only: %i[create destroy]
    resources :enrollments,  only: %i[create destroy]
    member do
      # Bewusste Demo-Schwachstelle (T3 Security): PII-Export, siehe CoursesController#participants.
      get :participants
    end
  end

  # Wurzel ist der öffentliche Marketplace; die Admin-Verwaltung liegt unter /courses.
  root "catalog#index"
end
