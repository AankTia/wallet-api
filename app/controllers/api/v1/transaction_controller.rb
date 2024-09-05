module Api
  module V1
    class TransactionController < Api::V1::BaseController

      def initialize
        super
        @transaction_service = Api::V1::TransactionService.new
      end

      def deposit
        deposit_params = params.require(:transaction).permit(:amount)
        
        amount_validator = validate_amount(deposit_params[:amount])
        if amount_validator.valid?
          render_json_result(@transaction_service.deposit(@wallet, deposit_params[:amount]))
        else
          render_json_unprocessable_entity(amount_validator.message)
        end
      end

      def withdraw
        withdraw_params = params.require(:transaction).permit(:amount)
        
        amount_validator = validate_amount(withdraw_params[:amount])
        if amount_validator.valid?
          render_json_result(@transaction_service.withdraw(@wallet, withdraw_params[:amount]))
        else
          render_json_unprocessable_entity(amount_validator.message)
        end
      end

      private

      AmountValidator = Struct.new(:valid?, :message)
      def validate_amount(value)
        invalid_messages = nil
        if value.present?
          if [Float, Integer].include?(value.class)
            invalid_messages = 'Must be grater than 0' if value <= 0
          else
            invalid_messages = 'is Not a Number Format'
          end
        else
          invalid_messages = 'is Empty'
        end

        if invalid_messages.present?
          invalid_messages = "Request Cannot Be Processed, Amount #{invalid_messages}"
        end

        AmountValidator.new(!invalid_messages.present?, invalid_messages)
      end

    end
  end
end