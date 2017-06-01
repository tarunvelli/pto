namespace :config do
  desc "rake task to reset leaves every year for user"
  task reset_leaves_every_year: :environment do
    users = User.all
    users.each do |user|
      user.total_leaves = user.remaining_leaves = NO_OF_PTO
      user.save!
    end
  end
end
