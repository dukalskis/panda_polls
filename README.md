# PandaPolls

https://pandapolls.fly.dev

## Setup

Install Elixir and Erlang. For local app development, the [asdf](https://asdf-vm.com/) solution has been used; refer to the Elixir and Erlang versions in the `.tool-versions` file.

Run the app locally:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

App is fully prepared to be deployed on the fly.io platform as well.

## Why this project?

The app was created as a homework.

## Requirements

Build a simple polling application using Phoenix LiveView. The application should allow users to create new polls, vote in polls, and see real-time updates of the poll results. The solution should not use any external dependencies, such as a database or disk storage, and should instead store all needed data in application memory. 

- The solution should be built with Phoenix LiveView.
- Users should be able to create account by inserting their username.
- Users should be able to create new polls.
- Users should be able to vote in existing polls.
- Users should be able to see real-time updates of the poll results.
- You are free to use any Elixir/Erlang library and any open-source CSS framework for the design.
- Performance: users actions should not be blocking each other. User 1 actions should not be blocked by user 2 actions.
- The application should not use any external dependencies, such as a database or disk storage. - All needed data should be stored in application memory.
- The application should start with mix phx.server so it can be started locally.
- The application should be well-structured, and the code should be readable.

## About

To store data in memory, I decided to use ETS for data storage. The other option would be to use GenServer, however, with larger data volumes and loads, it would be a slow solution. Another advantage of using ETS is the available Ecto adapter - [etso](https://github.com/evadne/etso). It is used in this project. Of course, there are various limitations to that approach, but the code is much more readable, easier to understand, and if necessary, replacing ETS with an external database is much easier.

In tables, UUIDv7 is used as the primary ID, ensuring that the record ID values are sequential. If necessary, they can be sorted based on them, and it's more difficult for users to guess other record ID values.

The data is divided into 2 groups - users and polls.

Initially, using the `mix phx.gen.auth` command, code for user data processing was generated. Since an external DB is not used, the generated code was simply modified to work with "etso". To ensure user (by username) uniqueness, a GenServer is used - it processes only one registration at a time.

A similar solution for uniqueness (preventing double voting) is implemented for voting. Additionally, for each poll, a GenServer is spawned, which ensures better performance under heavier loads, as the workload is distributed across processes.

In the project, I use the Tailwind CSS framework. The design is inspired by Neo Brutalism.

The page functionality has been tested on both desktop and mobile devices.

Tests also cover core business functionality.
