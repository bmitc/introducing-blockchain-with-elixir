defmodule Blockchain.Extensions.SmartContracts do
  @moduledoc """
  Smart contracts
  """

  alias Blockchain.Transaction
  alias Blockchain.Wallet

  @typedoc """
  Represents the possible operators that can be used in a contract
  """
  @type operator :: :+ | :* | :- | :== | :> | :< | :and | :or

  @typedoc """
  Represents a contract expression
  """
  @type contract ::
          number()
          | String.t()
          | []
          | {}
          | binary()
          | {:if, contract(), contract(), contract()}
          | {operator(), contract(), contract()}
          | :from
          | :to
          | :value
          | any()

  @doc """
  Determines if both the transcation and the contract are valid or not
  """
  @spec valid_transaction_contract?(Transaction.t(), contract()) :: boolean()
  def valid_transaction_contract?(%Transaction{} = transaction, contract) do
    eval(transaction, contract) and Transaction.valid?(transaction)
  end

  @doc """
  Evaluates a contract against a transaction
  """
  @spec eval(Transaction.t(), contract()) ::
          number() | String.t() | boolean() | contract() | Wallet.t()
  def eval(%Transaction{from: from, to: to, value: value} = t, contract) do
    case contract do
      x when is_number(x) -> x
      s when is_binary(s) -> s
      [] -> true
      {} -> true
      true -> true
      false -> false
      {:if, condition, tr, fa} -> if eval(t, condition), do: eval(t, tr), else: eval(t, fa)
      {:+, left, right} -> eval(t, left) + eval(t, right)
      {:*, left, right} -> eval(t, left) * eval(t, right)
      {:-, left, right} -> eval(t, left) - eval(t, right)
      {:==, left, right} -> eval(t, left) == eval(t, right)
      {:>, left, right} -> eval(t, left) > eval(t, right)
      {:<, left, right} -> eval(t, left) < eval(t, right)
      {:and, left, right} -> eval(t, left) and eval(t, right)
      {:or, left, right} -> eval(t, left) or eval(t, right)
      :from -> from
      :to -> to
      :value -> value
      _ -> false
    end
  end
end
