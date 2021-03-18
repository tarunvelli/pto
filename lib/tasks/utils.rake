# frozen_string_literal: true

namespace :utils do
  desc 'rake task to set start and end date for existing ooo configs'
  task set_start_and_end_dates_for_existing_ooo_configs: :environment do
    OOOConfig.all.each do |ooo_config|
      years = ooo_config.financial_year.split('-')

      start_date = Date.new(years[0].to_i, 4, 1)
      end_date = Date.new(years[1].to_i, 3, 31)
      financial_year = "#{years[0]}/04-#{years[01]}/03"
      
      ooo_config.update_attributes!(
        start_date: start_date, end_date: end_date, financial_year: financial_year
      )
    end
  end

  desc 'rake task seed intermediate year'
  task seed_intermediate_year: :environment do
    OOOConfig.create!(
      financial_year: '2021/04-2021/12',
      leaves_count: 20,
      wfhs_count: 0,
      wfh_penalty_coefficient: 0,
      wfh_headsup_hours: 0,
      start_date: '2021-04-01',
      end_date: '2021-12-31'
    )
  end

  desc 'rake task to remove old papertrail versions'
  task remove_old_paper_trail_versions: :environment do
    sql = "delete from versions where created_at < '2020-04-01'"
    ActiveRecord::Base.connection.execute(sql)
    sql = "select count(*) from versions where created_at < '2020-04-01'"
    results = ActiveRecord::Base.connection.execute(sql)

    puts results.to_a
  end
end
