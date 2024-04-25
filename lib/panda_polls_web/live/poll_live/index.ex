defmodule PandaPollsWeb.PollLive.Index do
  use PandaPollsWeb, :live_view

  alias PandaPolls.Polls

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:user_id, socket.assigns.current_user.id)
     |> stream(:polls, Polls.list_polls())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:new), do: "New Poll"
  defp page_title(:index), do: "Polls"

  # @impl true
  # def handle_info({RedWeb.ProductLive.FormComponent, {:saved, product}}, socket) do
  #   {:noreply, stream_insert(socket, :polls, product)}
  # end
end
