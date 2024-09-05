class Deposit < Transaction
  after_create :increase_wallet_balance

  def increase_wallet_balance
    ballance_before = wallet.balance

    begin
      if !amount.zero?
        wallet.credit(amount)
        if wallet.balance > ballance_before
          update(status: SUCCESS)
        else
          wallet.update!(balance: ballance_before) if wallet.balance != ballance_before
          update(status: FAILED, notes: 'Failed to increase Wallet balance')
        end
      end
    rescue Exception => e
      wallet.update!(balance: ballance_before) if wallet.balance != ballance_before
      update(status: ERROR, notes: e.message)
    end
  end
end