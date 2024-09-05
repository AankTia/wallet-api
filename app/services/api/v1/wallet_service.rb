module Api::V1
  class WalletService

    def get_balance(user)
      wallet = user.wallet
      if wallet.present?
        return {
          status: :success,
          data: {
            phone_number: user.phone_number,
            balance: wallet.balance,
            balance_with_currency: wallet.balance_with_currency
          }
        }
      else
        return {
          status: :data_not_found,
          data: {
            message: "Wallet is not Exists"
          }
        }
      end
    end
  end
end