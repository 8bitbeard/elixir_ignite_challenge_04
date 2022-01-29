defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"
  @file_list ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "parallel_build/1" do
    test "When passing a file list return a report" do
      response= GenReport.parallel_build(@file_list)

      assert response == ReportFixture.build()
    end

    test "When passing a single file, returns an error" do
      response = GenReport.parallel_build(@file_name)

      assert response == {:error, "Favor fornecer uma lista de arquivos!"}
    end

    test "When no list of filenames is given, returns an error" do
      response = GenReport.parallel_build()

      assert response == {:error, "Favor fornecer uma lista de arquivos!"}
    end
  end
end
