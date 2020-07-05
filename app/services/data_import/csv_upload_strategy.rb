# frozen_string_literal: true

module DataImport
  class CsvUploadStrategy
    attr_reader :file_path, :form_class, :imported_count

    def initialize(file_path:, form_class:)
      @file_path = file_path
      @form_class = form_class
      @imported_count = 0
    end

    def upload
      parsed_csv.each do |csv_params|
        in_transaction do
          form_class.process(csv_params)
        end
      end
      puts("Imported: #{imported_count}, Total: #{parsed_csv.size}")
    end

    private

    def parsed_csv
      @parsed_csv ||= SmarterCSV.process(file_path)
    end

    def in_transaction
      ActiveRecord::Base.transaction do
        yield
      end
      @imported_count += 1
    rescue ActiveRecord::RecordInvalid
      false
    end
  end
end
