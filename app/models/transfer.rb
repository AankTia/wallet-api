class Transfer < Transaction
  belongs_to :receiver_wallet, class_name: 'Wallet', index: true

  validates_presence_of :receiver_wallet
  validate :amount_less_than_or_equal_to_sender_wallet_balance, if: :amount_present?

  after_create :update_wallet_balance

  def update_wallet_balance
    sender_ballance_before = wallet.balance
    receiver_ballance_before = receiver_wallet.balance
    
    begin
      if !amount.zero?
        wallet.debit(amount)
        receiver_wallet.credit(amount)
        if (wallet.balance < sender_ballance_before) && (receiver_wallet.balance > receiver_ballance_before)
          update(status: SUCCESS)
        else
          err_messages = []
          err_messages << 'Failed to Decrease Source Wallet Balance' unless wallet.balance < sender_ballance_before  
          err_messages << 'Failed to Increase Destination Wallet Balance' unless receiver_wallet.balance > receiver_ballance_before

          wallet.update!(balance: sender_ballance_before)
          receiver_wallet.update!(balance: receiver_ballance_before)

          update(status: FAILED, notes: err_messages.to_sentence)
        end
      end
    rescue Exception => e
      wallet.update!(balance: sender_ballance_before)
      receiver_wallet.update!(balance: receiver_ballance_before)
      
      update(status: ERROR, notes: e.message)
    end
  end

  private

  def amount_less_than_or_equal_to_sender_wallet_balance
    if amount > wallet.balance
      errors.add(:amount, message: "Exceeds Sender Wallet Balance")
    end
  end
end