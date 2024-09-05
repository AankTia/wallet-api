module Api
  module V1
    class WalletController < Api::V1::BaseController

      def initialize
        super
        @wallet_service = Api::V1::WalletService.new
      end

      def balance
        result_data = @wallet_service.get_balance(@current_user)
        render_json_result result_data
      end

    end
  end
end