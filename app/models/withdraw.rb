class Withdraw < Transaction
  validate :amount_less_than_or_equal_to_balance

  after_create :decrease_wallet_balance

  def decrease_wallet_balance
    ballance_before = wallet.balance

    begin
      if !amount.zero?
        wallet.debit(amount)
        if wallet.balance < ballance_before
          update(status: SUCCESS)
        else
          wallet.update!(balance: ballance_before) if wallet.balance != ballance_before
          update(status: FAILED, notes: 'Failed to decrease Wallet balance')
        end
      end
    rescue Exception => e
      wallet.update!(balance: ballance_before) if wallet.balance != ballance_before
      update(status: ERROR, notes: e.message)
    end
  end

  private

  def amount_less_than_or_equal_to_balance
    if amount > wallet.balance
      errors.add(:amount, message: "is greater than Balance")
    end
  end
end