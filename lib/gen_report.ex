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

  def parallel_build(filenames) when not is_list(filenames) do
    {:error, "Favor fornecer uma lista de arquivos!"}
  end

  def parallel_build(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(empty_report(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  def parallel_build() do
    {:error, "Favor fornecer uma lista de arquivos!"}
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

  defp sum_reports(%{"all_hours" => all_hours1, "hours_per_month" => hours_per_month1, "hours_per_year" => hours_per_year1},
  %{"all_hours" => all_hours2, "hours_per_month" => hours_per_month2, "hours_per_year" => hours_per_year2}) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = merge_inner_maps(hours_per_month1, hours_per_month2)
    hours_per_year = merge_inner_maps(hours_per_year1, hours_per_year2)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _k, v1, v2 -> v1 + v2 end)
  end

  defp merge_inner_maps(map1, map2) do
    Map.merge(map1, map2, fn _k, v1, v2 -> merge_maps(v1, v2) end)
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
