# frozen_string_literal: true

require('rails_helper')
Rails.application.load_tasks

describe('Rake::Task["merchants:import"]') do
  subject(:upload) do
    Rake::Task['merchants:import'].invoke(csv_file.path)
  end
  let(:csv_file) { generate_csv(csv_data) }

  context 'DataImport::MerchantForm' do
    let(:csv_data) do
      [
        {
          'email' => 'csvmerchant0@mail.com',
          'name' => 'name0',
          'status' => 'inactive',
          'description' => 'description'
        },
        {
          'email' => 'csvmerchant1@mail.com',
          'name' => 'name1'
        },
        {
          'email' => 'csvmerchant0@mail.com',
          'name' => 'nameother'
        }
      ]
    end
    it 'creates merchants' do
      expect { upload }
        .to(change { Merchant.all.reload.count }.by(2))
      merchant = Merchant.find_by(email: 'csvmerchant0@mail.com')
      expect(merchant.name).to(eql('name0'))
      expect(merchant.status).to(eql(:inactive))
      expect(merchant.description).to(eql('description'))
      expect(Merchant.where(email: 'csvmerchant1@mail.com').exists?).to(eql(true))
    end
  end
end
