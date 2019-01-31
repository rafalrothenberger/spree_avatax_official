require 'spec_helper'

describe SpreeAvataxOfficial::Transactions::RefundService do
  describe '#call', :vcr do
    let(:subject) do
      described_class.call(
        return_authorization: create(:return_authorization, order: order)
      )
    end
    let(:result) { subject.value }

    before { SpreeAvataxOfficial::Config.company_code = 'test1' }

    context 'with commited order' do
      let(:order) { create(:shipped_order, number: 'REFUNDTEST123') }

      it 'creates refund transaction' do
        VCR.use_cassette('spree_avatax_official/transactions/refund/success') do
          result = subject
          response = result.value

          expect(result.success?).to eq true
          expect(response['type']).to eq 'ReturnInvoice'
          expect(SpreeAvataxOfficial::Transaction.count).to eq 1
        end
      end
    end

    context 'with uncomitted order' do
      let(:order) { create(:shipped_order, number: 'REFUNDTEST456') }

      it 'returns error' do
        VCR.use_cassette('spree_avatax_official/transactions/refund/error') do
          result = subject
          response = result.value

          expect(result.failure?).to eq true
          expect(response['error']['code']).to eq 'InvalidDocumentStatusForRefund'
          expect(SpreeAvataxOfficial::Transaction.count).to eq 0
        end
      end
    end
  end
end