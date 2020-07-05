# frozen_string_literal: true

require('rails_helper')

describe 'Admin Merchants' do
  let(:admin) { create(:admin) }

  before do
    login_as(admin, scope: :admin)
  end

  context 'index' do
    let!(:merchant) do
      create(
        :merchant,
        name: 'name_string',
        description: 'description_text',
        email: 'email@mail.com',
        total_transaction_sum: 321,
        status: :active
      )
    end
    let!(:other_merchant) do
      create(
        :merchant,
        name: 'name_string_other',
        description: 'description_text_other',
        email: 'other_email@mail.com',
        total_transaction_sum: 123,
        status: :inactive
      )
    end
    it 'show merchants' do
      visit admin_merchants_path
      expect(page).to(have_selector('td', text: 'email@mail.com'))
      expect(page).to(have_selector('td', text: 'name_string'))
      expect(page).to(have_selector('td', text: 'active'))
      expect(page).to(have_selector('td', text: 'description_text'))
      expect(page).to(have_selector('td', text: '321'))
      expect(page).to(have_selector('td', text: 'other_email@mail.com'))
      expect(page).to(have_selector('td', text: 'name_string_other'))
      expect(page).to(have_selector('td', text: 'inactive'))
      expect(page).to(have_selector('td', text: 'description_text_other'))
      expect(page).to(have_selector('td', text: '123'))
    end
  end

  context 'create new merchant' do
    before(:each) do
      visit new_admin_merchant_path
      within('form') do
        fill_in 'Name', with: 'merchant_name'
        fill_in 'merchant[password]', with: '123456'
        fill_in 'Password confirmation', with: '123456'
        fill_in 'Description', with: 'description_after'
      end
    end

    it 'should be successful' do
      within('form') do
        fill_in 'Email', with: 'new_merchant@mail.com'
      end
      click_button 'Create Merchant'
      expect(page).to(have_content('Merchant was successfully created.'))
      expect(current_path).to(be_eql(admin_merchant_path(Merchant.last)))
      expect(page).to(have_selector('dd', text: 'new_merchant@mail.com'))
      expect(page).to(have_selector('dd', text: 'merchant_name'))
      expect(page).to(have_selector('dd', text: 'active'))
      expect(page).to(have_selector('dd', text: 'description_after'))
    end

    it 'should fail' do
      click_button 'Create Merchant'
      expect(page).to(have_content('Email can\'t be blank'))
    end
  end

  context 'update user' do
    let(:merchant) do
      create(
        :merchant,
        name: 'name_before',
        description: 'description_before',
        email: 'email_before@mail.com',
        status: :active
      )
    end
    it 'should be successful' do
      visit edit_admin_merchant_path(merchant)
      within('form') do
        fill_in 'Name', with: 'name_after'
        fill_in 'Email', with: 'email_after@mail.com'
        fill_in 'merchant[password]', with: '123456'
        fill_in 'Password confirmation', with: '123456'
        fill_in 'Description', with: 'description_after'
        select 'inactive', from: 'Status'
      end
      click_button 'Update Merchant'
      expect(page).to(have_content('Merchant was successfully updated.'))
      expect(current_path).to(be_eql(admin_merchant_path(merchant)))
      expect(page).to(have_selector('dd', text: 'email_after@mail.com'))
      expect(page).to(have_selector('dd', text: 'name_after'))
      expect(page).to(have_selector('dd', text: 'inactive'))
      expect(page).to(have_selector('dd', text: 'description_after'))
    end

    it 'should fail' do
      visit edit_admin_merchant_path(merchant)
      within('form') do
        fill_in 'merchant[password]', with: '123456'
        fill_in 'Password confirmation', with: 'other'
      end
      click_button 'Update Merchant'
      expect(page).to(have_content("Password confirmation doesn't match Password"))
    end
  end

  context 'destroy merchant' do
    context 'no transactions' do
      let!(:merchant) do
        create(
          :merchant,
          name: 'name_string',
          description: 'description_text',
          email: 'email@mail.com',
          payment_transactions_count: 0,
          status: :active
        )
      end
      it 'should be successful' do
        visit admin_merchants_path
        expect(page).to(have_link('Destroy'))
        accept_confirm do
          click_link 'Destroy'
        end
        expect(page).to(have_content('Merchant was successfully destroyed.'))
        expect(Merchant.where(id: merchant.id).exists?).to(eql(false))
      end
    end
    context 'with counter cache' do
      let!(:merchant) do
        create(
          :merchant,
          name: 'name_string',
          description: 'description_text',
          email: 'email@mail.com',
          payment_transactions_count: 321,
          status: :active
        )
      end
      it 'no link to destroy' do
        visit admin_merchants_path
        expect(page).to(have_no_link('Destroy'))
      end
    end
  end
end
