# frozen_string_literal: true

require('rails_helper')

describe(DataImport::CsvUploadStrategy) do
  subject(:uploader) do
    described_class.new(
      file_path: csv_file.path,
      form_class: form_class
    )
  end
  let(:upload) { uploader.upload }
  let(:csv_file) { generate_csv(csv_data) }

  shared_examples 'not creates users' do |users_scope|
    it do
      expect { upload }
        .to_not(change { users_scope.reload.count })
    end
  end
  shared_examples 'creates users' do |users_scope, users_count|
    it do
      expect { upload }
        .to(change { users_scope.reload.count }.by(users_count))
    end
  end

  context 'DataImport::AdminForm' do
    let(:form_class) { DataImport::AdminForm }
    let(:csv_data) do
      [
        {
          'email' => 'admin0@mail.com',
          'id' => 789_654
        },
        {
          'email' => 'admin1@mail.com'
        },
        {
          'email' => 'admin0@mail.com'
        }
      ]
    end

    it_behaves_like 'creates users', Admin.all, 2
    it 'prints statistics' do
      expect { upload }
        .to(output("Imported: 2, Total: 3\n").to_stdout)
    end
    it 'ignore not supported parameters' do
      upload
      expect(Admin.find_by(email: 'admin0@mail.com').id)
        .to_not(eql(789_654))
    end
    context 'admin with admin1@mail.com already present' do
      before do
        create(:admin, email: 'admin1@mail.com')
      end
      it_behaves_like 'creates users', Admin.all, 1
      it 'prints statistics' do
        expect { upload }
          .to(output("Imported: 1, Total: 3\n").to_stdout)
      end
    end
  end

  context 'DataImport::MerchantForm' do
    let(:form_class) { DataImport::MerchantForm }
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

    it_behaves_like 'creates users', Merchant.all, 2
    it 'prints statistics' do
      expect { upload }
        .to(output("Imported: 2, Total: 3\n").to_stdout)
    end
    it 'set correct params' do
      upload
      merchant = Merchant.find_by(email: 'csvmerchant0@mail.com')
      expect(merchant.name).to(eql('name0'))
      expect(merchant.status).to(eql(:inactive))
      expect(merchant.description).to(eql('description'))
    end
    context 'merchant with csvmerchant1@mail.com already present' do
      before do
        create(:merchant, email: 'csvmerchant1@mail.com')
      end
      it_behaves_like 'creates users', Merchant.all, 1
      it 'prints statistics' do
        expect { upload }
          .to(output("Imported: 1, Total: 3\n").to_stdout)
      end
    end
  end
end
