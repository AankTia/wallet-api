module Api::V1
  class TransactionService

    def detail(user, transaction_id)
      transaction = Transaction.find(transaction_id)

      is_valid_transaction = false
      if transaction.present?
        is_valid_transaction = (user.id == transaction&.wallet&.user_id) ||
                                  transaction.transfer_type? && user.id == transaction&.receiver_wallet&.user_id
      end

      if is_valid_transaction
        return { status: :success, data: generate_transaction_detail(transaction) }
      else
        return { status: :data_not_found, data: { message: "Transaction is not Exists" } }
      end
    end

    def history(wallet)
      datas = wallet.transactions.order_by(updated_at: :desc)
                    .map{ |tr| generate_transaction_detail(tr) }
      return { status: :success, data: datas }
    end

    def deposit(wallet, amount)
      if !wallet.present?
        return { status: :data_not_found, data: { message: "Wallet is not Exists" } }
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

    def withdraw(wallet, amount)
      if !wallet.present?
        return { status: :data_not_found, data: { message: "Wallet is not Exists" } }
      end
      
      wallet_number = wallet&.user&.phone_number
      balance_with_currency_before = wallet.balance_with_currency

      withdraw = Withdraw.new(wallet_id: wallet.id, amount: amount)
      if withdraw.save
        wallet.reload

        if withdraw.is_success?
          { 
            status: :success, 
            data: { 
              message: 'Withdraw successful',
              wallet: {
                number: wallet&.user&.phone_number,
                balance: {
                  before: balance_with_currency_before,
                  after: wallet.balance_with_currency
                }
              },
              transaction: {
                id: withdraw.id.to_s,
                type: withdraw._type,
                status: withdraw.status
              }
            }
          }
        else
          { 
            status: :failed, 
            data: { 
              message: withdraw.notes,
              wallet: {
                number: wallet&.user&.phone_number,
                balance: {
                  before: balance_with_currency_before,
                  after: wallet.balance_with_currency
                }
              },
              transaction: {
                id: withdraw.id.to_s,
                type: withdraw._type,
                status: withdraw.status
              }
            }
          }
        end
      else
        { 
          status: :failed, 
          data: { 
            message: withdraw.errors.full_messages.to_sentence,
            wallet: {
              number: wallet&.user&.phone_number,
              balance: {
                before: balance_with_currency_before,
                after: wallet&.reload&.balance_with_currency
              }
            },
            transaction: {
              type: withdraw._type
            }
          }
        }
      end
    end

    def transfer(sender_number: nil, receiver_number: nil, amount: nil)
      data_result = {
        message: '',
        amount: amount,
        sender_wallet: {},
        receiver_wallet: {},
        transaction: {}
      }

      transfer_data = validate_transfer_data(sender_number: sender_number, receiver_number: receiver_number, amount: amount)
      if transfer_data.valid?
        sender_balance_with_currency_before = transfer_data.sender_wallet.balance_with_currency
        receiver_balance_with_currency_before = transfer_data.receiver_wallet.balance_with_currency

        transaction = Transfer.new(
          wallet_id: transfer_data.sender_wallet&.id, 
          receiver_wallet_id: transfer_data.receiver_wallet&.id,
          amount: amount
        )
        if transaction.save
          transfer_data.sender_wallet.reload
          transfer_data.receiver_wallet.reload

          data_result[:message] = transaction.notes
          data_result[:transaction] = {
            type: transaction._type,
            id: transaction.id.to_s,
            status: transaction.status
          }
          data_result[:sender_wallet] = {
            number: transfer_data.sender_wallet&.user&.phone_number,
            balance: {
              before: sender_balance_with_currency_before,
              after: transfer_data.sender_wallet.balance_with_currency
            }
          }
          data_result[:receiver_wallet] = {
            number: transfer_data.receiver_wallet&.user&.phone_number,
            balance: {
              before: receiver_balance_with_currency_before,
              after: transfer_data.receiver_wallet.balance_with_currency
            }
          }

          if transaction.is_success?
            return { status: :success, data: data_result }
          else
            return { status: :failed, data: data_result }
          end
        else
          data_result[:message] = transaction.errors.full_messages.to_sentence
          return { status: :failed, data: data_result }
        end
      else
        data_result[:message] = transfer_data.error_messages
        return { status: :failed, data: data_result }
      end
    end

    private

    def generate_transaction_detail(transaction)
      data = {
        id: transaction.id.to_s,
        type: transaction._type,
        amount: transaction.amount,
        status: transaction.status,
        notes: transaction.notes,
        transaction_at: transaction.updated_at.to_s,
        wallet: {
          phone_number: transaction&.wallet&.phone_number,
          user_fullname: transaction&.wallet&.user&.fullname
        }
      }

      if transaction.transfer_type?
        data[:receiver] = {
          phone_number: transaction&.receiver_wallet&.phone_number,
          user_fullname: transaction&.receiver_wallet&.user.fullname
        }
      end

      data
    end

    def validate_transfer_data(sender_number: nil, receiver_number: nil, amount: nil)
      result = Struct.new('TransferValidatorResult', :valid?, :sender_wallet, :receiver_wallet, :amount, :error_messages)

      sender_wallet = nil
      receiver_wallet = nil
      error_messages = []

      if sender_number.present?
        sender_wallet = Wallet.find_by_phone_number(sender_number)
        if sender_wallet.present? 
          if amount.present?
            if amount > sender_wallet.balance
              error_messages << 'Transfer Amount Exceeds Sender Wallet Balance'
            end
          else
            error_messages << 'Amount is Empty' 
          end
        else
          error_messages << 'Sender Wallet is Not Exists'
        end
      else
        error_messages << 'Sender Wallet Number is Empty'
      end

      if receiver_number.present?
        receiver_wallet = Wallet.find_by_phone_number(receiver_number)
        error_messages << 'Receiver Wallet is not exists' unless receiver_wallet.present?
      else
        error_messages << "Receiver Wallet Number is Empty"
      end

      error_messages = error_messages.to_sentence

      result.new(!error_messages.present?, sender_wallet, receiver_wallet, amount, error_messages)
    end
  end
end