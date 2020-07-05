# frozen_string_literal: true

require('rails_helper')
Rails.application.load_tasks

describe('Rake::Task["admins:import"]') do
  subject(:upload) do
    Rake::Task['admins:import'].invoke(csv_file.path)
  end
  let(:csv_file) { generate_csv(csv_data) }

  context 'DataImport::MerchantForm' do
    let(:csv_data) do
      [
        {
          'email' => 'csvadmin0@mail.com'
        },
        {
          'email' => 'csvadmin1@mail.com'
        },
        {
          'email' => 'csvadmin0@mail.com',
          'name' => 'nameother'
        }
      ]
    end
    it 'creates merchants' do
      expect { upload }
        .to(change { Admin.all.reload.count }.by(2))
      expect(Admin.where(email: 'csvadmin0@mail.com').exists?).to(eql(true))
      expect(Admin.where(email: 'csvadmin1@mail.com').exists?).to(eql(true))
    end
  end
end
