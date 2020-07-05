# frozen_string_literal: true

require('rails_helper')

describe PaymentTransactionsRemovingJob do
  describe '#process' do
    let(:current_time) { Time.utc(2016, 8, 1, 13, 30) }
    let(:merchant) { create(:merchant, total_transaction_sum: 30) }
    let(:other_merchant) { create(:merchant, total_transaction_sum: 30) }
    let(:old_authorize_transaction) { create(:authorize_transaction, merchant: merchant, amount: 20) }
    let(:new_authorize_transaction) { create(:authorize_transaction, merchant: other_merchant, amount: 20) }
    let(:new_charge_transaction) { create(:charge_transaction, merchant: other_merchant, amount: 10) }
    let(:old_charge_transaction1) do
      create(
        :charge_transaction,
        merchant: merchant,
        authorize_transaction: old_authorize_transaction,
        amount: 5
      )
    end
    let(:old_charge_transaction2) do
      create(
        :charge_transaction,
        merchant: merchant,
        authorize_transaction: old_authorize_transaction,
        amount: 5
      )
    end
    let(:old_refund_transaction) do
      create(
        :refund_transaction,
        merchant: merchant,
        charge_transaction: old_charge_transaction1,
        amount: 5
      )
    end
    let(:old_reversal_transaction) do
      create(
        :reversal_transaction,
        merchant: merchant,
        authorize_transaction: old_authorize_transaction,
        amount: 5
      )
    end
    subject(:remove_old_job) { described_class.perform_now }

    before do
      Timecop.freeze(current_time - 65.minutes)
      old_charge_transaction1
      old_charge_transaction2
      old_reversal_transaction
      old_refund_transaction
      Timecop.freeze(current_time)
      new_charge_transaction
    end

    def is_exists?(transaction)
      expect(PaymentTransaction.where(id: transaction.id).exists?).to(be_truthy)
    end

    def is_removed?(transaction)
      expect(PaymentTransaction.where(id: transaction.id).exists?).to(be_falsey)
    end

    it 'change counter count for merchant' do
      expect { subject }
        .to(change { PaymentTransaction.all.count }.by(-5))
    end

    it 'removes all dependent transactions' do
      subject
      is_removed?(old_charge_transaction1)
      is_removed?(old_charge_transaction2)
      is_removed?(old_reversal_transaction)
      is_removed?(old_refund_transaction)
      is_removed?(old_authorize_transaction)
    end

    it 'not removes new transactions' do
      subject
      is_exists?(new_charge_transaction)
      is_exists?(new_authorize_transaction)
    end

    it 'change counter cache for merchant' do
      expect { subject }
        .to(change { merchant.reload.payment_transactions_count }.by(-5))
    end
  end
end
