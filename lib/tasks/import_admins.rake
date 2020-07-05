# frozen_string_literal: true

namespace :admins do
  desc 'Import admins from a CSV file'
  task :import, [:csv_file_path] => [:environment] do |_task, args|
    DataImport::CsvUploadStrategy.new(
      file_path: args[:csv_file_path],
      form_class: DataImport::AdminForm
    ).upload
  end
end
