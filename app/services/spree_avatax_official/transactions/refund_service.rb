module SpreeAvataxOfficial
  module Transactions
    class RefundService < SpreeAvataxOfficial::Base
      def call(refundable:)
        refund_transaction(refundable).tap do |response|
          return request_result(response) do
            create_transaction!(
              code:             response['code'],
              order:            order(refundable),
              transaction_type: SpreeAvataxOfficial::Transaction::RETURN_INVOICE
            )
          end
        end
      end

      private

      def refund_transaction(refundable)
        order = order(refundable)

        client.refund_transaction(
          company_code,
          order.number,
          refund_model(order)
        )
      end

      def order(refundable)
        case refundable
        when ::Spree::ReturnAuthorization
          refundable.order
        when ::Spree::ReturnItem
          refundable.return_authorization.order
        end
      end

      def refund_model(order)
        FullRefundPresenter.new(order: order).to_json
      end
    end
  end
end
