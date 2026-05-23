defmodule TippingWeb.HealthControllerTest do
  use TippingWeb.ConnCase, async: true

  describe "GET /api/healthz" do
    test "status is 200", %{conn: conn} do
      conn = get(conn, ~p"/api/health")
      assert response(conn, 200)
    end
  end
end
