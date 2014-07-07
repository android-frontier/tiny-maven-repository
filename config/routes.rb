Rails.application.routes.draw do
  # NOTE: see http://guides.rubyonrails.org/routing.html
  # how to debug:
  # console> reload! ; Rails.application.routes.recognize_path '/release/com/android-frontier/foo/1.0.0/foo-1.0.0.jar', method: :get

  root to: 'artifacts#index'

  # see http://docs.codehaus.org/display/MAVEN/Repository+Layout+-+Final
  # /$groupId[0]/../${groupId[n]/$artifactId/$version/$artifactId-$version.$extension
  resources :artifacts do # artifact upload API
    collection do
      put '/*artifact_path/:filename', to: 'artifacts#publish',
          constraints: {
              filename: /.+/,
          }

      get '/*artifact_path/:filename', to: 'artifacts#show',
          constraints: {
              filename: /.+/,
          }
    end
  end
end
