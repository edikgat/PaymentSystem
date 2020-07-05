# frozen_string_literal: true

module CsvHelper
  def generate_csv(csv_data)
    csv_string =
      CSV.generate do |csv|
        csv << csv_data.first.keys
        csv_data.reduce(csv) do |acc, row|
          acc << row.values
        end
      end

    file = Tempfile.new
    file.write(csv_string)
    file.rewind
    file
  end

  def generate_empty_csv
    file = Tempfile.new
    file.write(' ')
    file.rewind
    file
  end
end

RSpec.configure do |c|
  c.include(CsvHelper)
end
