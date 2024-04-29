defmodule PandaPollsWeb.PollLive.FormComponent do
  use PandaPollsWeb, :live_component

  alias PandaPolls.Polls

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        for={@form}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <% # Question %>

        <.input field={@form[:question]} type="text" label="Question" />

        <% # Answers %>

        <.error :for={msg <- @form[:answers].errors}>
          <%= translate_error(msg) %>
        </.error>

        <div :if={is_list(@form[:answers].value)} class="flex flex-col">
          <.inputs_for :let={answer_f} field={@form[:answers]}>
            <input type="hidden" name="poll[answers_sort][]" value={answer_f.index} />
            <div class="mb-4 flex justify-between gap-6">
              <.input field={answer_f[:answer]} type="text" label="Answer" />
              <label>
                <input
                  type="checkbox"
                  name="poll[answers_drop][]"
                  value={answer_f.index}
                  class="hidden"
                />
                <.icon
                  name="hero-x-mark"
                  class="w-8 h-8 relative top-10 bg-black hover:bg-brand hover:cursor-pointer"
                />
              </label>
            </div>
          </.inputs_for>
        </div>

        <% # Errors block %>

        <.error_block :if={@show_error_block}>
          Looks like there are errors in your form. Please review and correct them before saving.
        </.error_block>

        <% # Buttons %>

        <:actions>
          <label class={[
            "h-12 border-black border-2 p-2.5 bg-white font-medium",
            "hover:shadow-[2px_2px_0px_rgba(0,0,0,1)]",
            "focus:outline-none focus:shadow-[2px_2px_0px_rgba(0,0,0,1)]"
          ]}>
            <input type="checkbox" name="poll[answers_sort][]" class="hidden" /> Add Answer
          </label>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    # show 2 empty answers for a new form
    answers = %{answers: [%{answer: ""}, %{answer: ""}]}

    changeset = Polls.change_poll(answers)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:show_error_block, false)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    poll_params = user_id_to_params(socket.assigns, poll_params)

    changeset =
      poll_params
      |> Polls.change_poll()
      |> Map.put(:action, :validate)

    show_error_block = socket.assigns.show_error_block && not changeset.valid?

    {:noreply,
     socket
     |> assign(:show_error_block, show_error_block)
     |> assign_form(changeset)}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    poll_params = user_id_to_params(socket.assigns, poll_params)

    case Polls.create_poll(poll_params) do
      {:ok, _poll} ->
        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:show_error_block, true)
         |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp user_id_to_params(%{user_id: user_id}, params) do
    Map.put(params, "user_id", user_id)
  end
end
