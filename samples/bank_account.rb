#
# This example was ported from 
# https://metacpan.org/pod/Moose::Cookbook::Basics::BankAccount_MethodModifiersAndSubclassing

require 'moosex'

class BankAccount
  include MooseX

  has balance: {
    is: :rw,
    isa: Integer,
    default: 0,
  }

  def deposit(amount)
    self.balance += amount
  end

  def withdraw(amount)
    current_balance = self.balance 

    raise "Acount overdrawn" if amount > current_balance

    self.balance= current_balance - amount

  end
end

ba = BankAccount.new(balance: 100)

ba.deposit(50)

puts ba.balance # should be 150

ba.withdraw(70) 

puts ba.balance # should be 80

begin
  ba.withdraw(999)
rescue =>e
  puts "can't withdraw 999: #{e}"
end

class CheckingAccount < BankAccount
 
  has overdraft_account: {
    is: :rw, 
    isa: BankAccount, 
    predicate: true,
    handles: { 
      withdraw_from_overdraft_account: :withdraw
    },
  }

  before(:withdraw) do |account, amount|
    overdraft_amount = amount - account.balance

    if account.has_overdraft_account? && overdraft_amount > 0

      account.withdraw_from_overdraft_account( overdraft_amount )

      account.deposit(overdraft_amount )

    end
  end

end

ba = BankAccount.new(balance: 1000)
ca1 = CheckingAccount.new(balance: 1000, overdraft_account: ba)
ca2 = CheckingAccount.new(balance: 1000)

ca1.withdraw(1500)

puts ca1.balance # should print 0
puts ba.balance # should print 500

begin
  ca2.withdraw(1500)
rescue => e
  puts "can't withdraw 1500: #{e}"
end
