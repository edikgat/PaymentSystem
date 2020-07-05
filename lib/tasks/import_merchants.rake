# frozen_string_literal: true

namespace :merchants do
  desc 'Import merchants from a CSV file'
  task :import, [:csv_file_path] => [:environment] do |_task, args|
    DataImport::CsvUploadStrategy.new(
      file_path: args[:csv_file_path],
      form_class: DataImport::MerchantForm
    ).upload
  end
end
