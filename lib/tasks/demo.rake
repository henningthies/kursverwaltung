namespace :demo do
  desc "Setzt die Demo-Datenbank auf den reproduzierbaren Startzustand zurück"
  task reset: :environment do
    Rake::Task["db:reset"].invoke
  end
end
