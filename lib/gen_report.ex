defmodule GenReport do
  alias GenReport.Parser

  @workers [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius",
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(empty_report(), fn line, report -> sum_values(line, report) end)
  end

  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  defp sum_values([name, hours, _day, month, year],
  %{"all_hours" => all_hours, "hours_per_month" => hours_per_month, "hours_per_year" => hours_per_year}) do
    all_hours = Map.put(all_hours, name, all_hours[name] + hours)
    month_map = Map.put(hours_per_month[name], month, hours_per_month[name][month] + hours)
    hours_per_month = Map.put(hours_per_month, name, month_map)
    year_map = Map.put(hours_per_year[name], year, hours_per_year[name][year] + hours)
    hours_per_year = Map.put(hours_per_year, name, year_map)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  def empty_report do
    months_map = Enum.into(@months, %{}, &{&1, 0})
    years_map = Enum.into(@years, %{}, &{&1, 0})
    all_hours = Enum.into(@workers, %{}, &{&1, 0})
    hours_per_month = Enum.into(@workers, %{}, &{&1, months_map})
    hours_per_year = Enum.into(@workers, %{}, &{&1, years_map})

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{"all_hours" => all_hours, "hours_per_month" => hours_per_month, "hours_per_year" => hours_per_year}
  end
end
