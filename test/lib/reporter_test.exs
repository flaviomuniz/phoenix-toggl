defmodule PhoenixToggl.RepoterTest do
  use PhoenixToggl.ModelCase, async: true

  alias PhoenixToggl.Reports.{Reporter}
  alias PhoenixToggl.{TimeEntryActions}
  alias Timex.{Date, Time, DateFormat}

  setup do
    user = create(:user)

    now = Date.now
    start_date = Date.beginning_of_week(now, :mon)
  end_date = Date.end_of_week(now, :mon)

    for day_number <- 0..6 do
      started_at =  start_date
        |> Date.add(Time.to_timestamp(day_number, :days))

      stopped_at = started_at
        |> Date.add(Time.to_timestamp(4, :hours))

      %{
        name: "Default",
        user_id: user.id,
        started_at: started_at
      }
      |> TimeEntryActions.start
      |> TimeEntryActions.stop(stopped_at)
    end

    {:ok, user: user, start_date: start_date, end_date: end_date}
  end

  test "invalid params" do
    assert Reporter.generate(%{}) == {:error, :invalid_params}
    assert Reporter.generate() == {:error, :invalid_params}
  end

  test "valid params", %{user: user, start_date: start_date, end_date: end_date} = params do
    data = Reporter.generate(params)

    assert data.user_id == user.id
    assert data.start_date == start_date |> DateFormat.format!("%Y-%m-%d", :strftime)
    assert data.end_date == end_date |> DateFormat.format!("%Y-%m-%d", :strftime)
    assert length(data.days) == 7

    for day <- data.days  do
      assert day.duration == 4 * 3600
    end

    assert data.total_duration == 7 * 4 * 3600
  end
end
