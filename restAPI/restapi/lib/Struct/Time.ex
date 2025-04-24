defmodule MyTime do
  @enforce_keys [:year, :month, :day, :hour, :minute]
  defstruct [:year, :month, :day, :hour, :minute]

  @moduledoc """
  MyTime struct for time management
  keys [:year, :month, :day, :hour, :minute]

  method:
  - converter/1: convert string to MyTime struct
  - getraw/1: get raw time value from MyTime struct
  - getraw/2: get raw time value from MyTime struct with format
  - get_to_string/1: convert MyTime struct to string
  - get_to_string/2: convert MyTime struct to string with format
  - compare/2: compare two MyTime structs
  - compare/3: compare two MyTime structs with format
  - get_to_string_korean/2: convert MyTime struct to string with format

  formats:
  - :date: "YYYY:MM:DD"
  - :short: "HH:MM"
  - any: "YYYY:MM:DD:HH:MM"
  """
  def converter(%MyTime{} = msg), do: msg

  def converter(msg) do
    [year, month, day, hour, minute] =
      msg
      |> String.split(":")

    %MyTime{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute
    }
  end

  def getraw(%MyTime{} = t) do
    String.to_integer(t.year) * 1_000_000_000 + String.to_integer(t.month) * 1_000_000 +
      String.to_integer(t.day) * 1_000 + String.to_integer(t.hour) * 100 +
      String.to_integer(t.minute)
  end

  def getraw(%MyTime{} = t, format) do
    case format do
      :date ->
        String.to_integer(t.year) * 1_000_000_000 + String.to_integer(t.month) * 1_000_000 +
          String.to_integer(t.day) * 1_000

      :short ->
        String.to_integer(t.hour) * 100 + String.to_integer(t.minute)

      _ ->
        getraw(t)
    end
  end

  def get_to_string(%MyTime{} = t) do
    "#{t.year}:#{t.month}:#{t.day}:#{t.hour}:#{t.minute}"
  end

  def get_to_string(%MyTime{} = t, format) do
    case format do
      :date -> "#{t.year}:#{t.month}:#{t.day}"
      :short -> "#{t.hour}:#{t.minute}"
      _ -> get_to_string(t)
    end
  end

  def compare(%MyTime{} = t1, %MyTime{} = t2) do
    getraw(t1) > getraw(t2)
  end

  def compare(%MyTime{} = t1, %MyTime{} = t2, format) do
    case format do
      :date ->
        getraw(t1, :date) > getraw(t2, :date)

      :short ->
        getraw(t1, :short) > getraw(t2, :short)

      _ ->
        getraw(t1) > getraw(t2)
    end
  end

  def get_to_string_korean(%MyTime{} = t, format) do
    case format do
      :date ->
        "#{t.year}년 #{t.month}월 #{t.day}일"

      :short ->
        "#{t.hour}시 #{t.minute}분"

      _ ->
        get_to_string(t, format)
    end
  end
end
