desc "binds server to chosen (local) ip"

namespace :db do
  task :recreate do
    sh "rails db:drop; rails db:create; rails db:migrate; rails db:seed"
  end
end