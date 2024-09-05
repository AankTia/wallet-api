module Api::V1
  class TransactionService

    def deposit(wallet, amount)
      if !wallet.present?
        return { 
          status: :data_not_found, 
          data: { message: "Wallet is not Exists" }
        }
      end
      
      wallet_number = wallet&.user&.phone_number
      balance_before = wallet.balance_with_currency

      deposit = Deposit.new(wallet_id: wallet.id, amount: amount)
      if deposit.save
        if deposit.is_success?
          { 
            status: :success, 
            data: { 
              message: 'Deposit successful',
              wallet: {
                number: wallet&.user&.phone_number,
                balance: {
                  before: balance_before,
                  after: wallet&.reload&.balance_with_currency
                }
              },
              transaction: {
                id: deposit.id.to_s,
                type: deposit._type,
                status: deposit.status
              }
            }
          }
        else
          { 
            status: :failed, 
            data: { 
              message: deposit.notes,
              wallet: {
                number: wallet&.user&.phone_number,
                balance: {
                  before: balance_before,
                  after: wallet&.reload&.balance_with_currency
                }
              },
              transaction: {
                id: deposit.id.to_s,
                type: deposit._type,
                status: deposit.status
              }
            }
          }
        end
      else
        { 
          status: :failed, 
          data: { 
            message: deposit.errors.full_messages.to_sentence,
            wallet: {
              number: wallet&.user&.phone_number,
              balance: {
                before: balance_before,
                after: wallet&.reload&.balance_with_currency
              }
            },
            transaction: {}
          }
        }
      end
    end
  end
end