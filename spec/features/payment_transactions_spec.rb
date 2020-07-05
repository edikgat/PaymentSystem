# frozen_string_literal: true

require('rails_helper')

describe 'PaymentTransactions' do
  let(:admin) { create(:admin) }
  let(:merchant) do
    create(
      :merchant,
      name: 'MerchantFirst',
      status: :active,
      total_transaction_sum: 999
    )
  end
  let(:authorize_transaction) do
    create(
      :authorize_transaction,
      uuid: 'auth123',
      amount: 10.0,
      merchant: merchant,
      customer_phone: '123456',
      customer_email: 'cust@mail.com'
    )
  end
  let!(:charge_transaction) do
    create(
      :charge_transaction,
      authorize_transaction: authorize_transaction,
      uuid: 'charge123',
      amount: 5.0,
      merchant: merchant,
      customer_phone: '123456',
      customer_email: 'cust@mail.com'
    )
  end
  let(:other_merchant) do
    create(
      :merchant,
      name: 'MerchantOther'
    )
  end
  let!(:other_authorize_transaction) do
    create(
      :authorize_transaction,
      uuid: 'other_auth123',
      amount: 30.0,
      merchant: other_merchant,
      customer_phone: '987456',
      customer_email: 'other_cust@mail.com'
    )
  end

  context 'index' do
    context 'admin' do
      before do
        login_as(admin, scope: :admin)
        visit admin_payment_transactions_path
      end

      it 'display list of payment_transactions' do
        expect(page).to(have_link('auth123'))
        expect(page).to(have_link('charge123'))
        expect(page).to(have_link('other_auth123'))
        expect(page).to(have_link('MerchantFirst'))
        expect(page).to(have_link('MerchantOther'))
        expect(page).to(have_selector('td', text: 'AuthorizeTransaction'))
        expect(page).to(have_selector('td', text: 'ChargeTransaction'))
        expect(page).to(have_selector('td', text: '$10'))
        expect(page).to(have_selector('td', text: '$5'))
        expect(page).to(have_selector('td', text: '$30'))
        expect(page).to(have_selector('td', text: 'cust@mail.com'))
        expect(page).to(have_selector('td', text: 'other_cust@mail.com'))
        expect(page).to(have_selector('td', text: '123456'))
        expect(page).to(have_selector('td', text: '987456'))
      end
    end
    context 'merchant' do
      before do
        login_as(merchant, scope: :merchant)
        visit merchant_payment_transactions_path
      end

      it 'display list of payment_transactions' do
        expect(page).to(have_link('Total Profit: $999'))
        expect(page).to(have_link('auth123'))
        expect(page).to(have_link('charge123'))
        expect(page).to(have_no_link('other_auth123'))
        expect(page).to(have_no_link('MerchantFirst'))
        expect(page).to(have_no_link('MerchantOther'))
        expect(page).to(have_selector('td', text: 'AuthorizeTransaction'))
        expect(page).to(have_selector('td', text: 'ChargeTransaction'))
        expect(page).to(have_selector('td', text: '$10'))
        expect(page).to(have_selector('td', text: '$5'))
        expect(page).to(have_no_selector('td', text: '$30'))
        expect(page).to(have_selector('td', text: 'cust@mail.com'))
        expect(page).to(have_no_selector('td', text: 'other_cust@mail.com'))
        expect(page).to(have_selector('td', text: '123456'))
        expect(page).to(have_no_selector('td', text: '987456'))
      end
    end
  end
  context 'show' do
    context 'admin' do
      before do
        login_as(admin, scope: :admin)
        visit admin_payment_transaction_path(charge_transaction)
      end

      it 'show payment transaction' do
        expect(page).to(have_link('auth123'))
        expect(page).to(have_link('MerchantFirst'))
        expect(page).to(have_selector('dd', text: 'charge123'))
        expect(page).to(have_selector('dd', text: 'ChargeTransaction'))
        expect(page).to(have_selector('dd', text: '$5'))
        expect(page).to(have_selector('dd', text: 'cust@mail.com'))
        expect(page).to(have_selector('dd', text: '123456'))
      end
    end
    context 'merchant' do
      before do
        login_as(merchant, scope: :merchant)
        visit merchant_payment_transaction_path(charge_transaction)
      end

      it 'show payment transaction' do
        expect(page).to(have_link('auth123'))
        expect(page).to(have_no_link('MerchantFirst'))
        expect(page).to(have_selector('dd', text: 'charge123'))
        expect(page).to(have_selector('dd', text: 'ChargeTransaction'))
        expect(page).to(have_selector('dd', text: '$5'))
        expect(page).to(have_selector('dd', text: 'cust@mail.com'))
        expect(page).to(have_selector('dd', text: '123456'))
      end
    end
  end
end
