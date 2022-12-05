# HNAggregator

## Development Notes

The main logic that periodically retrieves the 50 top stories from Hacker News
is located in `lib/hn_aggregator/worker.ex`.
This GenServer is supervised by the `HNAggregator.Supervisor` with a
_one_for_one_ strategy.

The code that interacts with the HN API is located in
`lib/hn_aggregator/hn_client.ex`. This module uses the Tesla HTTP client and
performs all the requests in parallel using supervised Tasks.

Code for the HTTP API and WebSocket endpoint is located under `lib/hn_aggregator/api/`.
The `HTTPController` module defines the functions that handle the requests
dispatched by the router.
The `WebSocketHandler` module implements the `cowboy_websocket` behaviour and
uses the Registry in order to dispatch the stories to the clients connected to
the websocket endpoint.

## Public APIs

### HTTP
The HTTP API provides the following endpoints:
- localhost:4040/stories: lists the top stories with pagination (e.g: /stories?page=3)
- localhost:4040/stories/:id: retrieves a single top story (e.g: /stories/33843069)

### WebSocket
When connecting to ws://localhost:4040/ws the top stories are sent
To test this, the following Javascript code can be input in the browser console:
```js
socket = new WebSocket("ws://localhost:4040/ws")
socket.addEventListener("message", (event) => {
  console.log(event.data)
})
```
Every 5 minutes the top stories list will be refreshed.

## Essential Constraints
All major components of the application (Router, worker, and Registry) are supervised
by the `HNAggregator.Supervisor`.
Other internal components such as the Tasks used when calling the HN API are
supervised by an ad-hoc supervisor.

Data is always kept in memory. This application uses ETS in order to enable
multiple processes to read the stored data concurrently.
The ETS table is protected so the Worker is the only process that can write
data to the table.

## Nice To Haves
- Non blocking operations: Accomplished.
- Testing: Not implemented. (Due to personal issues I only had one day to
  implement the application and could not achieve this requirement)
- Type and function specifications: Accomplished
- Skip Phoenix scaffold: No framework was used. For the API only the following
  libraries were used: cowboy, plug, and plug_cowboy.
- Release strategy: Accomplished. The project uses `mix release`.
- Isolation strategy: Accomplished. A Dockerfile was provided

