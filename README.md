# DFTBLW

Implementation of the example projects in the Designing Elixir Systems
with OTP book.

The book advocates for building systems using some combination of the following _layers_:

* Data Structures (Do)
* Functional Core (Fun)
* Tests (Things)
* Boundaries (Big)
* Lifecycle (Loud)
* Workers (Worker-bees)

Providing the mnemonic:

> Do fun things with big, loud worker-bees

A unit of software that honors these concepts is named a _component_.

To help understand these layers, two components will be built.
This is the first.

This component will count things in isolation.
The data is an integer and does not need to persist through failures and
restarts.

## The Layers
Here is a summary of the different layers.

Not every program will need every single layer, but thinking in terms of these
layers will help understand Elixir's development.

The *data*, *functions*, and *tests* are the internal building blocks of
projects.
The datatype will guide the structure of the component and will later drive the
interactions between functions.

The *boundaries*, *life-cycles*, and *workers* layers relate to how parts of the
component work together.
Getting the boundaries right is the secret to dealing with small pieces of
complexity at a time.

### Data Structures
The data layer has the data structures our functions will use.
When the data structure is correct, the functions holding the algorithms that do
things can seem to write themselves.
Getting this wrong will make the functions feel clumsy and wrong.

This layer should express the concepts in the component as data.

Some main considerations at this layer:
* How idiomatic and efficient
* Influence on design of functions
* Cohesion trade-offs, i.e. how close related data is grouped.

The data layer in this case is simple, it's an integer.

### Functional Core
Also known as the _business logic_.

This layer should  be agnostic to the machinery related to processes.
It should not try preserve state or contain side effects.
It is made up of functions.

This allows us to isolate the complexity of the _machinery_ we need to manage
processes, side-effects, etc. from the inherit complexity of our _domain_.

This layer should follow 2 rules:
1. It must have no side effects, meaning it should not alter state
2. A function invoked with same inputs will always return the same outputs

In this case, our business logic is to increment a value.

### Tests
The tests that make sure the system works as expected.

By structuring code into core and boundary layers is simplified testing.
With a basic API that does most of the business logic, writing tests to
thouroughly cover the code will be easier.

Testing the Functional Core code is easier and more predictable, and will
recieve the bulk of the testing focus.
It is easier as external conditions won't be a factor and much of the logic will
be contained in the functional core layer.

### Boundaries
This layer deals with side effects and state.
Often it will deal with processes and where the API is presented to outside
world.

Often, when dealing with state in Elixir, you use processes along side recursion
and message passing.
OTP GenServers will normally provide those concepts.

Precisely, a _boundary layer_ is:
* A Server, i.e. the machinery of processes, message passing, and recursion that form the hear
    of concurrency in Elixir systems.
* An API, i.e. plain functions that hides the machinery from clients.

In this case, we will build the above concepts from scratch without reaching for
a GenServer.
This is to demystify OTP and show what is happening under the hood.

### Life-cycle
This layer deals with starting and stopping cleanly, this is where Elixir's
_supervision_ comes in.
Once we can start cleanly and detect failures, _failove_ is almost free.

This is the premise of the supervision strategy that underpins Elixir.

The counter life-cycle is flawed as any failure will result in the failure of
the counter, an any systems that rely on it.
We could add this to our counter but Elixir provides OTP which handles that for
us.

The main idea here is that life-cycle is a fundamental principle of design.

### Workers
Workers are the different processes in the component.
They handle things like cleaning up life-cycles or concurrently dividing work
and are things like connection pools, tasks, and agents.

In the counter component, the worker is the Server.

Workers and life-cycle are closely related, as once your introduce a process (or
worker) you must also consider the life-cycle.
